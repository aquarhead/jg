//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"

@interface JGStartPageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation JGStartPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.animationImages = @[[UIImage imageNamed:@"start1"], [UIImage imageNamed:@"start2"]];
    self.imageView.animationDuration = 15;
    [self.imageView startAnimating];
}

@end
