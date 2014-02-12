//
//  JGSubmitPageTableViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 2/12/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGSubmitPageTableViewController.h"

@interface JGSubmitPageTableViewController ()

@end

@implementation JGSubmitPageTableViewController

- (IBAction)pay:(id)sender {
    [self.delegate pay];
}

- (IBAction)submit:(id)sender {
    [self.delegate submit];
}

@end
