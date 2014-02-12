//
//  JGSubmitPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 1/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGSubmitPageViewController.h"
#import "JGSubmitPageTableViewController.h"
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import <YLProgressBar.h>

@interface JGSubmitPageViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet YLProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) JGSubmitPageTableViewController *staticTableVC;

@property (weak, nonatomic) NSFNanoObject *book;

@property (nonatomic) AFHTTPRequestOperationManager *jgServerManager;
@property (nonatomic) NSUInteger finished;

@end

@implementation JGSubmitPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.book = self.poolViewController.book;

    self.progressBar.type = YLProgressBarTypeFlat;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    self.progressBar.behavior = YLProgressBarBehaviorDefault;
    self.progressBar.hideStripes = YES;
    self.progressBar.progressTintColor = [UIColor colorWithRed:235/255.0f green:180/255.0f blue:113/255.0f alpha:1.0f];
    // color from http://nipponcolors.com/#usukoh

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.jgServerManager = [AFHTTPRequestOperationManager manager];

    unsigned long long totalsize = 0;
    for (ALAsset *p in self.photos) {
        totalsize += p.defaultRepresentation.size;
    }
    self.staticTableVC.totalSizeLabel.text = [NSString stringWithFormat:@"%lld bytes", totalsize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embed"]) {
        self.staticTableVC = segue.destinationViewController;
    }
}

- (IBAction)createPayment:(id)sender {
    self.staticTableVC.paymentButton.enabled = NO;
    [self.staticTableVC.recpField resignFirstResponder];
    [self.staticTableVC.phoneField resignFirstResponder];
    [self.staticTableVC.addressTextview resignFirstResponder];
    NSDictionary *parameters = @{@"info": self.book.info, @"recp": self.staticTableVC.recpField.text, @"phone": self.staticTableVC.phoneField.text, @"address": self.staticTableVC.addressTextview.text};
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book.key];
    [self.jgServerManager POST:addr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.staticTableVC.paymentButton.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.staticTableVC.paymentButton.enabled = YES;
    }];
}

- (IBAction)submit:(id)sender {
    if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        [self checkStatus];
    } else if ([AFNetworkReachabilityManager sharedManager].reachableViaWWAN) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有无线网络连接" message:@"上传照片会消耗很多流量，继续使用蜂窝数据网络上传吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有网络连接" message:@"请连接网络以上传照片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)checkStatus
{
    self.staticTableVC.submitButton.enabled = NO;
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book.key];
    [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqualToString:@"toupload"]) {
            [self doSubmit];
        } else if ([responseObject[@"status"] isEqualToString:@"topay"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您还未付款" message:@"请先付款，如有其他问题请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            self.staticTableVC.submitButton.enabled = YES;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片已上传过" message:@"如有其他问题请联系客服" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.staticTableVC.submitButton.enabled = YES;
    }];
}

- (void)doSubmit
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.operationQueue.maxConcurrentOperationCount = 1;
    self.finished = 0;
    [self.progressBar setProgress:0 animated:YES];

    for (ALAsset *p in self.photos) {
        ALAssetRepresentation *rep = p.defaultRepresentation;
        NSURL *data_url = rep.url;
        Byte *buffer = (Byte*)malloc((unsigned)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(unsigned)rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        NSMutableDictionary *options = [NSMutableDictionary new];
        options[@"bucket"] = @"jikangachou";
        options[@"expiration"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + 600];
        options[@"save-key"] = [NSString stringWithFormat:@"/%@/%@.JPG", self.book.key, [data_url query]];
        NSString *policy = [[NSJSONSerialization dataWithJSONObject:[options copy] options:0 error:nil] base64EncodedStringWithOptions:0];
        NSString *sig = [[NSString stringWithFormat:@"%@&DWAPWXDv2cLI7MuZmJRWq63r0T8=", policy] MD5Digest];
        NSDictionary *parameters = @{@"policy": policy, @"signature": sig};
        [manager POST:@"http://v0.api.upyun.com/jikangachou" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"file.JPG" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self finishOne];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.staticTableVC.submitButton.enabled = YES;
        }];
    }
}

- (void)finishOne
{
    self.finished += 1;
    [self.progressBar setProgress:(1.0*self.finished / self.photos.count) animated:YES];
    if (self.finished == self.photos.count) {
        NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/uploaded/", self.book.key];
        [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject[@"status"] isEqualToString:@"toprint"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片上传完成" message:@"我们会立刻付印您的相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.staticTableVC.submitButton.enabled = YES;
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self checkStatus];
    }
}

@end
