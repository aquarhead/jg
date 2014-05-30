//
//  JGDescriptionTableViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 5/30/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGDescriptionTableViewController.h"

@interface JGDescriptionTableViewController ()

@end

@implementation JGDescriptionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
