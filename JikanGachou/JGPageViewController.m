//
//  JGPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/17/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGPageViewController.h"

@interface JGPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation JGPageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.testLabel.text = self.pageIndex;
}

@end
