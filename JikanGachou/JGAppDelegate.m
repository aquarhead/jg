//
//  JGAppDelegate.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/1/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGAppDelegate.h"
#import <TestFlight.h>

@implementation JGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"c762250a-8bf5-4716-9065-8caf1bf40b61"];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [self.rootVC openWithBookUUID:[url query]];
    return YES;
}

@end
