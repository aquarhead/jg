//
//  JGShowPagesViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/16/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGShowPagesViewController.h"
#import "JGPageViewController.h"
#import "JGPhotoObject.h"
#import "JGDescriptionTableViewController.h"

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
    
    self.pages = [NSMutableArray new];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@0 andType:kJGEditPageCover]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@1 andType:kJGEditPageTitle]];
    for (int i = 0; i < 20; i++) {
        [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@(i+2) andType:kJGEditPageTypeOneLandscape]];
    }
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@22 andType:kJGEditPageBackCover]];
    [self.pages addObject:[JGPageViewController pageViewControllerWithIndex:@23 andType:nil]];

    [self randomCover];
    [self generatePhotosForPage];
    [self updateBookPages];

    self.dataSource = self;

    [self setViewControllers:@[self.pages[0], self.pages[1]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.photosForPage) {
        [self updateBookPages];
    }
}

- (void)randomCover
{
    JGPageViewController *coverVC = [self.pages objectAtIndex:1];
    NSMutableArray *photos = [self.photos mutableCopy];
    [photos shuffle];
    for (int i=1; i<=8; i++) {
        [coverVC.mainView fillCoverNth:i withPhotoObject:photos[i]];
    }
}

- (void)generatePhotosForPage
{
    NSMutableArray *nums = [NSMutableArray arrayWithArray:@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19]];
    [nums shuffle];
    self.photosForPage = [NSMutableArray new];
    for (int i=0; i<20; i++) {
        self.photosForPage[i] = [NSMutableArray arrayWithObject:self.photos[i]];
    }
    for (int i=0; i<[self.photos count] - 20; i++) {
        [self.photosForPage[[nums[i] integerValue]] addObject:self.photos[20+i]];
    }
}

- (void)updateBookPages
{
    self.tapRecogs = [NSMutableArray new];

    for (int i = 0; i < 20; i++) {
        NSMutableArray *photos = self.photosForPage[i];
        JGPageViewController *thisPageVC = [self.pages objectAtIndex:i+2];
        JGPhotoObject *po1 = photos[0];
        if ([photos count] == 1) {
            ALAsset *p = po1.asset;
            UIImage *img = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
            CGSize size = img.size;
            if (size.width >= size.height) {
                [thisPageVC switchType:kJGEditPageTypeOneLandscape];
            } else {
                [thisPageVC switchType:kJGEditPageTypeOnePortrait];
            }
            [thisPageVC.mainView fillNth:1 withPhotoObject:po1];
            po1.imageView = thisPageVC.mainView.imageView1;
            UITapGestureRecognizer *tr = [self makeRecog];
            [self.tapRecogs addObject:tr];
            [thisPageVC setupRecogs:@[tr]];
        }
        else {
            JGPhotoObject *po2 = photos[1];
            // two photos
            ALAsset *p1 = po1.asset;
            ALAsset *p2 = po2.asset;
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
                    [thisPageVC switchType:kJGEditPageTypeTwoLandscape];
                } else {
                    [thisPageVC switchType:kJGEditPageTypeMixedLeftLandscape];
                }
            } else {
                if (p2_landscape) {
                    [thisPageVC switchType:kJGEditPageTypeMixedLeftPortrait];
                } else {
                    [thisPageVC switchType:kJGEditPageTypeTwoPortrait];
                }
            }

            // fill mainView
            [thisPageVC.mainView fillNth:1 withPhotoObject:po1];
            [thisPageVC.mainView fillNth:2 withPhotoObject:po2];
            po1.imageView = thisPageVC.mainView.imageView1;
            po2.imageView = thisPageVC.mainView.imageView2;

            UITapGestureRecognizer *tr1 = [self makeRecog];
            [self.tapRecogs addObject:tr1];
            UITapGestureRecognizer *tr2 = [self makeRecog];
            [self.tapRecogs addObject:tr2];
            [thisPageVC setupRecogs:@[tr1, tr2]];
        }
    }
    [self reloadInputViews];
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
    if (idx == ([self.pages count] - 1)) {
        return nil;
    }
    return [self.pages objectAtIndex:idx + 1];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editDescription"]) {
        JGDescriptionTableViewController *vc = segue.destinationViewController;
        vc.photoObj = self.selectedPhotoObj;
    }
}

#pragma mark - Set Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
