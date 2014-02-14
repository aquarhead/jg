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

@interface JGSubmitPageViewController () <UIAlertViewDelegate, JGSubmitPageTableDelegate>

@property (nonatomic) NSArray *photo_urls;
@property (nonatomic) NSArray *photos;
@property (nonatomic) ALAssetsLibrary *lib;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) JGSubmitPageTableViewController *staticTableVC;

@property (nonatomic) AFHTTPRequestOperationManager *jgServerManager;
@property (nonatomic) NSUInteger finished;

@end

@implementation JGSubmitPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lib = [ALAssetsLibrary new];
    NSMutableArray *photo_urls = [NSMutableArray new];
    if ([[self.book objectForKey:@"cover_type"] isEqualToString:@"EditPageCoverTypePhoto"]) {
        [photo_urls addObject:[self.book objectForKey:@"cover_photo"]];
    }
    for (int i=0; i<20; i++) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%d", i]];
        // all these checks are redundant
        if (page) {
            if (page[@"payload"][@"photo"]) {
                [photo_urls addObject:page[@"payload"][@"photo"]];
            }
            if (page[@"type"] && ![page[@"type"] hasPrefix:@"EditPageTypeOne"] && page[@"payload"][@"photo2"]) {
                [photo_urls addObject:page[@"payload"][@"photo2"]];
            }
        }
    }
    self.photo_urls = [photo_urls copy];
    NSMutableArray *photos = [NSMutableArray new];
    for (NSString *urlstr in self.photo_urls) {
        [self.lib assetForURL:[NSURL URLWithString:urlstr] resultBlock:^(ALAsset *asset) {
            [photos addObject:asset];
            self.photos = [photos copy];
            if (self.photos.count == self.photo_urls.count) {
                [self setTotalSize];
            }
        } failureBlock:^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法获取图片" message:@"请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }

    self.progressBar.trackTintColor = [UIColor whiteColor];
    self.progressBar.progressTintColor = [UIColor colorWithRed:125/255.0f green:185/255.0f blue:222/255.0f alpha:1.0f];
    // color from http://nipponcolors.com/#wasurenagusa

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.jgServerManager = [AFHTTPRequestOperationManager manager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embed"]) {
        self.staticTableVC = segue.destinationViewController;
        self.staticTableVC.actionDelegate = self;
    }
}

- (void)setTotalSize
{
    long long totalsize = 0;
    for (ALAsset *p in self.photos) {
        totalsize += p.defaultRepresentation.size;
    }
    self.staticTableVC.totalSizeLabel.text = [NSByteCountFormatter stringFromByteCount:totalsize countStyle:NSByteCountFormatterCountStyleBinary];
}

- (void)pay
{
    [self.staticTableVC.recpField resignFirstResponder];
    [self.staticTableVC.phoneField resignFirstResponder];
    [self.staticTableVC.addressTextview resignFirstResponder];
    if ([self.staticTableVC.recpField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写姓名" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.staticTableVC.recpField becomeFirstResponder];
    } else if ([self.staticTableVC.phoneField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写可用的手机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.staticTableVC.phoneField becomeFirstResponder];
    } else if ([self.staticTableVC.addressTextview.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写完整的地址" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.staticTableVC.addressTextview becomeFirstResponder];
    } else {
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            self.staticTableVC.paymentButton.enabled = NO;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.book options:0 error:nil];
            NSDictionary *parameters = @{@"info": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], @"recp": self.staticTableVC.recpField.text, @"phone": self.staticTableVC.phoneField.text, @"address": self.staticTableVC.addressTextview.text};
            NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book[@"key"]];
            [self.jgServerManager POST:addr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.staticTableVC.paymentButton.enabled = YES;
                if ([responseObject[@"status"] isEqualToString:@"done"]) {
                    NSURL *url = [NSURL URLWithString:[responseObject[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    [[UIApplication sharedApplication] openURL:url];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.staticTableVC.paymentButton.enabled = YES;
            }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有网络连接" message:@"请连接网络以上传照片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)submit
{
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
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book[@"key"]];
    [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqualToString:@"toupload"]) {
            [self uploadPhotos];
        } else if ([responseObject[@"status"] isEqualToString:@"topay"] || [responseObject[@"status"] isEqualToString:@"error"]) {
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

- (void)uploadPhotos
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
        options[@"save-key"] = [NSString stringWithFormat:@"/%@/%@.JPG", self.book[@"key"], [data_url query]];
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
        NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/uploaded/", self.book[@"key"]];
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

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self checkStatus];
    }
}

@end
