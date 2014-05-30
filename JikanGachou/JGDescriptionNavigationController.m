//
//  JGDescriptionNavigationController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 5/30/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGDescriptionNavigationController.h"

@interface JGDescriptionNavigationController ()

@end

@implementation JGDescriptionNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
