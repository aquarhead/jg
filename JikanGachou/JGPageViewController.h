//
//  JGPageViewController.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/17/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGShowPagesViewController.h"

static NSString * const kJGEditPageCover                  = @"EditPageCover";
static NSString * const kJGEditPageTitle                  = @"EditPageTitle";
static NSString * const kJGEditPageTypeOneLandscape       = @"EditPageTypeOneLandscape";
static NSString * const kJGEditPageTypeOnePortrait        = @"EditPageTypeOnePortrait";
static NSString * const kJGEditPageTypeMixedLeftLandscape = @"EditPageTypeMixedLeftLandscape";
static NSString * const kJGEditPageTypeMixedLeftPortrait  = @"EditPageTypeMixedLeftPortrait";
static NSString * const kJGEditPageTypeTwoLandscape       = @"EditPageTypeTwoLandscape";
static NSString * const kJGEditPageTypeTwoPortrait        = @"EditPageTypeTwoPortrait";
static NSString * const kJGEditPageBackCover              = @"EditPageBackCover";

@interface JGPageViewController : UIViewController <JGShowPagesContent>

@property (nonatomic, strong) NSNumber *pageIndex;

+ (JGPageViewController *)pageViewControllerWithIndex:(NSNumber *)idx andType:(NSString *)type;

- (void)switchType:(NSString *)type;

@end
