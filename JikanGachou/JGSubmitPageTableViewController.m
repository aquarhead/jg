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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.recpField becomeFirstResponder];
    } else if (indexPath.row == 1) {
        [self.phoneField becomeFirstResponder];
    } else if (indexPath.row == 2) {
        [self.addressTextview becomeFirstResponder];
    } else if (indexPath.row == 3) {
        [self.actionDelegate pay];
    } else if (indexPath.row == 5) {
        [self.actionDelegate submit];
    } else if (indexPath.row == 6) {
        [self.actionDelegate back];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
