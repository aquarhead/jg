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

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *dateField;

@property JGPhotoObject *photoObj;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation JGDescriptionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateField.inputView = self.datePicker;

    JGDescriptionNavigationController *navi = (JGDescriptionNavigationController *)self.navigationController;
    self.photoObj = navi.photoObj;
    if (![self.photoObj.text isEqualToString:@""]) {
        self.textField.text = self.photoObj.text;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.datePicker.date = self.photoObj.date;
    [self dateChanged:self];
}

- (IBAction)dateChanged:(id)sender {
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy年MM月dd日";
    }
    self.dateField.text = [formatter stringFromDate:self.datePicker.date];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    self.photoObj.text = self.textField.text;
    self.photoObj.date = self.datePicker.date;
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
