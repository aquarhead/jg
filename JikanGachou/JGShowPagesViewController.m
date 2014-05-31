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
#import "JGPhotoObject.h"
#import "JGDescriptionNavigationController.h"

#import <NSMutableArray+Shuffle.h>

@interface JGShowPagesViewController () <UIPageViewControllerDataSource>

@property (strong) NSMutableArray *pages;
@property (strong) NSMutableDictionary *book;
@property (strong) NSMutableArray *tapRecogs;
@property (strong) NSMutableArray *photosForPage;

@property JGPhotoObject *selectedPhotoObj;

@end

@implementation JGShowPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.book = [self.poolViewController.book mutableCopy];
    [self generatePhotosForPage];
    [self createBookPages];

    self.dataSource = self;

    [self setViewControllers:@[self.pages[0], self.pages[1]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)generatePhotosForPage
{
    NSMutableArray *nums = [NSMutableArray arrayWithArray:@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19]];
    [nums shuffle];
    self.photosForPage = [NSMutableArray new];
    for (int i = 0; i < 20; i++) {
        self.photosForPage[i] = [NSMutableArray arrayWithObject:self.photos[i]];
    }
    for (int i = 0; i < [self.photos count] - 20; i++) {
        [self.photosForPage[[nums[i] integerValue]] addObject:self.photos[20+i]];
    }
}

- (void)createBookPages
{
    self.tapRecogs = [NSMutableArray new];

    self.pages = [NSMutableArray new];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@0 andType:kJGEditPageCover]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@1 andType:kJGEditPageTitle]];
    for (int i = 0; i < 20; i++) {
        NSMutableDictionary *page = [NSMutableDictionary new];
        NSMutableArray *photos = self.photosForPage[i];
        JGPageViewController *thisPageVC = [JGPageViewController new];
        thisPageVC.pageIndex = @(i+2);
        if ([photos count] == 1) {
            ALAsset *p = [self.poolViewController photoWithURLString:((JGPhotoObject *)photos[0]).url];
            UIImage *img = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
            CGSize size = img.size;
            if (size.width >= size.height) {
                [thisPageVC switchType:kJGEditPageTypeOneLandscape];
                page[@"type"] = @"EditPageTypeOneLandscape";
            } else {
                [thisPageVC switchType:kJGEditPageTypeOnePortrait];
                page[@"type"] = @"EditPageTypeOnePortrait";
            }
            [thisPageVC.mainView fillNth:1 withPhoto:p];
            ((JGPhotoObject *)photos[0]).imageView = thisPageVC.mainView.imageView1;
            UITapGestureRecognizer *tr = [self makeRecog];
            [self.tapRecogs addObject:tr];
            [thisPageVC setupRecogs:@[tr]];
        }
        else {
            // two photos
            ALAsset *p1 = [self.poolViewController photoWithURLString:((JGPhotoObject *)photos[0]).url];
            ALAsset *p2 = [self.poolViewController photoWithURLString:((JGPhotoObject *)photos[1]).url];
            bool p1_landscape = NO, p2_landscape = NO;

            // check orientation
            CGSize size = [UIImage imageWithCGImage:p1.aspectRatioThumbnail].size;
            if (size.width >= size.height) {
                p1_landscape = YES;
            }
            CGSize size2 = [UIImage imageWithCGImage:p2.aspectRatioThumbnail].size;
            if (size2.width >= size2.height) {
                p2_landscape = YES;
            }

            // setup mainView
            if (p1_landscape) {
                if (p2_landscape) {
                    // two landscape
                    [thisPageVC switchType:kJGEditPageTypeTwoLandscape];
                    page[@"type"] = @"EditPageTypeTwoLandscape";
                } else {
                    // mixed left landscape
                    [thisPageVC switchType:kJGEditPageTypeMixedLeftLandscape];
                    page[@"type"] = @"EditPageTypeMixedLeftLandscape";
                }
            } else {
                if (p2_landscape) {
                    // mixed left portrait
                    [thisPageVC switchType:kJGEditPageTypeMixedLeftPortrait];
                    page[@"type"] = @"EditPageTypeMixedLeftPortrait";
                } else {
                    // two portrait
                    [thisPageVC switchType:kJGEditPageTypeTwoPortrait];
                    page[@"type"] = @"EditPageTypeTwoPortrait";
                }
            }

            // fill mainView
            [thisPageVC.mainView fillNth:1 withPhoto:p1];
            [thisPageVC.mainView fillNth:2 withPhoto:p2];
            ((JGPhotoObject *)photos[0]).imageView = thisPageVC.mainView.imageView1;
            ((JGPhotoObject *)photos[1]).imageView = thisPageVC.mainView.imageView2;

            UITapGestureRecognizer *tr1 = [self makeRecog];
            [self.tapRecogs addObject:tr1];
            UITapGestureRecognizer *tr2 = [self makeRecog];
            [self.tapRecogs addObject:tr2];
            [thisPageVC setupRecogs:@[tr1, tr2]];

            //            if (page[@"text2"] && ![page[@"text2"] isEqualToString:@""]) {
            //                [cell.mainView fillNth:2 withText:page[@"text2"]];
            //            }
        }
        [self.pages addObject:thisPageVC];
        NSString *pageKey = [NSString stringWithFormat:@"page%d", i];
        self.book[pageKey] = [page copy];
    }
    //    cell.mainView.delegate = self;
    //    if (page[@"text"] && ![page[@"text"] isEqualToString:@""]) {
    //        [cell.mainView fillNth:1 withText:page[@"text"]];
    //    }
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@22 andType:nil]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@23 andType:kJGEditPageBackCover]];
}

- (UITapGestureRecognizer *)makeRecog
{
    UITapGestureRecognizer *tapRecog = [UITapGestureRecognizer new];
    [tapRecog addTarget:self action:@selector(handleTap:)];
    tapRecog.numberOfTapsRequired = 1;
    tapRecog.numberOfTouchesRequired = 1;
    return tapRecog;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        for (JGPhotoObject *photoObj in self.photos) {
            if ([photoObj.imageView isEqual:sender.view]) {
                self.selectedPhotoObj = photoObj;
                break;
            }
        }
        [self performSegueWithIdentifier:@"editDescription" sender:self];
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editDescription"]) {
        JGDescriptionNavigationController *vc = segue.destinationViewController;
        vc.photoObj = self.selectedPhotoObj;
    }
}

@end
