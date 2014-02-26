//
//  JGBookTableViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 2/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGBookTableViewController.h"
#import <NyaruDB.h>

@interface JGBookTableViewController ()

@property (nonatomic) NSArray *books;

@end

@implementation JGBookTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NyaruDB *db = [NyaruDB instance];
    NyaruCollection *co = [db collection:@"books"];
    self.books = [[co all] fetch];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.books.count;
}

typedef NS_ENUM(NSUInteger, JGBookCellTag) {
    JGBookCellTagImageView = 100,
    JGBookCellTagBookName,
    JGBookCellTagBookStatus
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    UILabel *bookStatusLabel = (UILabel *)[cell viewWithTag:JGBookCellTagBookStatus];
    if (indexPath.row == 0) {
        bookStatusLabel.text = @"未付款 2014年1月1日";
    }

    NSDictionary *bk = self.books[indexPath.row];

    UILabel *bookNameLabel = (UILabel *)[cell viewWithTag:JGBookCellTagBookName];
    bookNameLabel.text = bk[@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
