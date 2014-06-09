//
//  JGAppDelegate.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/1/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGAppDelegate.h"

@implementation JGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [self.rootVC openWithBookUUID:[url query]];
    return YES;
}

@end
