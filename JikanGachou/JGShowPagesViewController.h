//
//  JGShowPagesViewController.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/16/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGImagePoolViewController.h"

@protocol JGShowPagesContent <NSObject>

- (NSUInteger)idx;

@end

@interface JGShowPagesViewController : UIPageViewController

@property (strong) NSArray *photos;
@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end
