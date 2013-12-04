//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import <iCarousel.h>

@interface JGStartPageViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@end

@implementation JGStartPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.scrollEnabled = YES;
    [self.carousel reloadData];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSString *imageName = [NSString stringWithFormat:@"start%lu", index+1];
    NSLog(@"%@", imageName);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:carousel.frame];
    imageView.image = [UIImage imageNamed:imageName];
    return imageView;
}

@end
