//
//  JGSubmitPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 1/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGSubmitPageViewController.h"
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import <YLProgressBar.h>

@interface JGSubmitPageViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet YLProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) NSFNanoObject *book;

@property (nonatomic) NSUInteger finished;

@end

@implementation JGSubmitPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.book = self.poolViewController.book;

    self.progressBar.type = YLProgressBarTypeFlat;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.progressBar.behavior = YLProgressBarBehaviorDefault;
    self.progressBar.hideStripes = YES;
    self.progressBar.progressTintColor = [UIColor colorWithRed:232/255.0f green:132/255.0f blue:12/255.0f alpha:1.0f];
    self.finished = 0;
}

- (IBAction)submit:(id)sender {
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        [self doSubmit];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有无线网络连接" message:@"上传照片会消耗很多流量，继续使用蜂窝数据网络上传吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
        [alertView show];
    }

}

- (void)doSubmit
{
    self.submitButton.enabled = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.operationQueue.maxConcurrentOperationCount = 1;

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
            self.submitButton.enabled = YES;
        }];
    }
}

- (void)finishOne
{
    self.finished += 1;
    [self.progressBar setProgress:(1.0*self.finished / self.photos.count) animated:YES];
    if (self.finished == self.photos.count) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片上传完成" message:@"我们会立刻付印您的相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self doSubmit];
    }
}

@end
