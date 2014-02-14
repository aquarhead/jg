//
//  JGAppDelegate.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/1/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGStartPageViewController.h"

@interface JGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) JGStartPageViewController *rootVC;

@end
