//
//  JGShowPagesViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/16/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGShowPagesViewController.h"
#import "JGPageViewController.h"

@interface JGShowPagesViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *vcs;

@end

@implementation JGShowPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.vcs = [NSMutableArray new];

    for (int i=0; i<20; i++) {
        JGPageViewController *vc = [JGPageViewController new];
        vc.pageIndex = [NSString stringWithFormat:@"%d", i];
        [self.vcs addObject:vc];
    }

    self.dataSource = self;
    [self setViewControllers:@[self.vcs[0], self.vcs[1]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

#pragma mark - PageVC DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    JGPageViewController *vc = (JGPageViewController *)viewController;
    NSUInteger idx = [vc.pageIndex integerValue];
    if (idx == 0) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    JGPageViewController *vc = (JGPageViewController *)viewController;
    NSUInteger idx = [vc.pageIndex integerValue];
    if (idx == [self.vcs count] - 1) {
        return nil;
    }
    return [self.vcs objectAtIndex:idx + 1];
}

@end
