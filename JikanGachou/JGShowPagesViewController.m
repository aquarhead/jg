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

@property (nonatomic, strong) NSMutableArray *pages;

@end

@implementation JGShowPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.pages = [NSMutableArray new];

    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@0 andType:nil]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@1 andType:kJGEditPageCover]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@2 andType:nil]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@3 andType:kJGEditPageTitle]];

    for (int i = 0; i < 20; i++) {
        [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@(i+4) andType:kJGEditPageTypeOneLandscape]];
    }

    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@24 andType:kJGEditPageBackCover]];

    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@25 andType:nil]];

    self.dataSource = self;
    [self setViewControllers:@[self.pages[0], self.pages[1]]
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
    return [self.pages objectAtIndex:idx - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    id<JGShowPagesContent> vc = (id<JGShowPagesContent>)viewController;
    NSUInteger idx = [vc idx];
    if (idx == [self.pages count] - 1) {
        return nil;
    }
    return [self.pages objectAtIndex:idx + 1];
}

@end
