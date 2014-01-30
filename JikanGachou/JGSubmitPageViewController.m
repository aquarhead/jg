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

@interface JGSubmitPageViewController ()

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation JGSubmitPageViewController

- (IBAction)submit:(id)sender {
    self.submitButton.enabled = NO;
    ALAsset *p = self.photos[0];
    ALAssetRepresentation *rep = p.defaultRepresentation;
    NSURL *data_url = rep.url;
    Byte *buffer = (Byte*)malloc((unsigned)rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(unsigned)rep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    NSMutableDictionary *options = [NSMutableDictionary new];
    options[@"bucket"] = @"jikangachou";
    options[@"expiration"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + 600];
    options[@"save-key"] = [NSString stringWithFormat:@"/%@.JPG", [data_url query]];
    NSString *policy = [[NSJSONSerialization dataWithJSONObject:[options copy] options:0 error:nil] base64EncodedStringWithOptions:0];
    NSString *sig = [[NSString stringWithFormat:@"%@&DWAPWXDv2cLI7MuZmJRWq63r0T8=", policy] MD5Digest];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    NSDictionary *parameters = @{@"policy": policy, @"signature": sig};
    [manager POST:@"http://v0.api.upyun.com/jikangachou" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file.JPG" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        self.submitButton.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.submitButton.enabled = YES;
    }];
}

@end
