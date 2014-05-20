//
//  JGPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/17/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGPageViewController.h"

@interface JGPageViewController ()

@end

@implementation JGPageViewController

+ (JGPageViewController *)pageViewControllerWithIndex:(NSNumber *)idx andType:(NSString *)type
{
    JGPageViewController *vc = [JGPageViewController new];
    vc.pageIndex = idx;
    if (type) {
        [vc switchType:type];
    }
    return vc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSUInteger)idx
{
    return [self.pageIndex intValue];
}

- (void)switchType:(NSString *)type
{
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }

    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:type owner:self options:nil] firstObject];
    [self.view addSubview:mainView];
}

@end
