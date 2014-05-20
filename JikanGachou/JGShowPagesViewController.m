//
//  JGShowPagesViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/16/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGShowPagesViewController.h"
#import "JGPageViewController.h"
#import "JGEditPageViewController.h"

@interface JGShowPagesViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *vcs;

@end

@implementation JGShowPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.vcs = [NSMutableArray new];

    JGPageViewController *vc = [JGPageViewController new];
    vc.pageIndex = @"0";
    [self.vcs addObject:vc];

    JGPageViewController *vc3 = [JGPageViewController new];
    vc3.pageIndex = @"1";
    [vc3 switchType:kJGEditPageCover];
    [self.vcs addObject:vc3];

    JGPageViewController *vc33 = [JGPageViewController new];
    vc33.pageIndex = @"2";
    [self.vcs addObject:vc33];

    JGPageViewController *vc4 = [JGPageViewController new];
    vc4.pageIndex = @"3";
    [vc4 switchType:kJGEditPageTitle];
    [self.vcs addObject:vc4];

    for (int i = 0; i < 20; i++) {
        JGPageViewController *vc = [JGPageViewController new];
        vc.pageIndex = [NSString stringWithFormat:@"%d", i + 4];
        [vc switchType:kJGEditPageTypeOneLandscape];
        [self.vcs addObject:vc];
    }

    JGPageViewController *vc2 = [JGPageViewController new];
    vc2.pageIndex = @"24";
    [vc2 switchType:kJGEditPageBackCover];
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
    id<JGShowPagesContent> vc = (id<JGShowPagesContent>)viewController;
    NSUInteger idx = [vc idx];
    if (idx == 0) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    id<JGShowPagesContent> vc = (id<JGShowPagesContent>)viewController;
    NSUInteger idx = [vc idx];
    if (idx == [self.vcs count] - 1) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx + 1];
}

@end
