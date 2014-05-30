//
//  JGBookContainerViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 5/18/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGBookContainerViewController.h"

@interface JGBookContainerViewController ()

@end

@implementation JGBookContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)backPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editDescription:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"editDescription" sender:self];
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
