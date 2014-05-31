//
//  JGDescriptionTableViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 5/30/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGDescriptionTableViewController.h"
#import "JGPhotoObject.h"
#import "JGDescriptionNavigationController.h"

@interface JGDescriptionTableViewController ()

@property JGPhotoObject *photoObj;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation JGDescriptionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    JGDescriptionNavigationController *navi = (JGDescriptionNavigationController *)self.navigationController;
    self.photoObj = navi.photoObj;
    if (![self.photoObj.text isEqualToString:@""]) {
        self.textField.text = self.photoObj.text;
    }
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    self.photoObj.text = self.textField.text;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.textField becomeFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
