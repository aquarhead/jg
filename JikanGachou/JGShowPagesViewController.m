//
//  JGShowPagesViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/16/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGShowPagesViewController.h"
#import "JGPageViewController.h"
#import "JGTransparentViewController.h"

@interface JGShowPagesViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *vcs;

@end

@implementation JGShowPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.vcs = [NSMutableArray new];

    JGTransparentViewController *vc = [JGTransparentViewController new];
    vc.pageIndex = @"0";

    [self.vcs addObject:vc];

    for (int i=0; i<20; i++) {
        JGPageViewController *vc = [JGPageViewController new];
        vc.pageIndex = [NSString stringWithFormat:@"%d", i+1];
        [self.vcs addObject:vc];
    }

    JGTransparentViewController *vc2 = [JGTransparentViewController new];
    vc2.pageIndex = @"21";

    [self.vcs addObject:vc2];

    self.dataSource = self;
    [self setViewControllers:@[self.vcs[0], self.vcs[1]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

#pragma mark - PageVC DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    id<JGShowPagesContent> vc = viewController;
    NSUInteger idx = [vc idx];
    if (idx == 0) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    id<JGShowPagesContent> vc = viewController;
    NSUInteger idx = [vc idx];
    if (idx == [self.vcs count] - 1) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx + 1];
}

@end
