//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import <iCarousel.h>

@interface JGStartPageViewController () <iCarouselDataSource, iCarouselDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *imagePickerController;

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

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSString *imageName = [NSString stringWithFormat:@"start%u", index+1];
    NSLog(@"%@", imageName);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:carousel.frame];
    imageView.image = [UIImage imageNamed:imageName];
    return imageView;
}

- (IBAction)buttonClicked:(id)sender
{
    [self showImagePicker];
}

- (void)showImagePicker
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

@end
