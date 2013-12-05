//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import <KIImagePager.h>

@interface JGStartPageViewController () <KIImagePagerDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation JGStartPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePager.dataSource = self;
    self.imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    self.imagePager.indicatorDisabled = YES;
    self.imagePager.slideshowTimeInterval = 7.0;
}

- (NSArray *)arrayWithImages
{
    return @[[UIImage imageNamed:@"start1"],
             [UIImage imageNamed:@"start2"]];
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleToFill;
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
