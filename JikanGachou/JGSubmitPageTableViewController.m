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
    [self.buttonDelegate pay];
}

- (IBAction)submit:(id)sender {
    [self.buttonDelegate submit];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
