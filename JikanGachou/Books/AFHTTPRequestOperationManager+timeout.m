//
//  AFHTTPRequestOperationManager+timeout.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 3/4/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "AFHTTPRequestOperationManager+timeout.h"

@implementation AFHTTPRequestOperationManager (timeout)

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];

    return operation;
}

@end
