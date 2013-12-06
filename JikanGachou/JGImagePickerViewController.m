//
//  JGImagePickerViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/6/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePickerViewController.h"

@interface JGImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation JGImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showImagePicker];
}

- (void)showImagePicker
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.delegate = self;

    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

@end
