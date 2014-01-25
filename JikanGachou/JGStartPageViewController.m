//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import <KIImagePager.h>

@interface JGStartPageViewController () <KIImagePagerDataSource>

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;

@end

@implementation JGStartPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagePager.dataSource = self;
    self.imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    self.imagePager.slideshowTimeInterval = 7.0;
    self.imagePager.imageCounterDisabled = YES;
}

- (NSArray *)arrayWithImages
{
    return @[[UIImage imageNamed:@"start1"],
             [UIImage imageNamed:@"start2"]];
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

@end
