//
//  JGBookTableViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 2/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGBookTableViewController.h"
#import "JGSubmitPageViewController.h"
#import <NyaruDB.h>

@interface JGBookTableViewController ()

@property (nonatomic) NSArray *books;
@property (nonatomic, weak) NSDictionary *selectedBook;

@end

@implementation JGBookTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NyaruDB *db = [NyaruDB instance];
    NyaruCollection *co = [db collection:@"books"];
    self.books = [[co all] fetch];
    [self.tableView reloadData];
    self.selectedBook = nil;
    if (self.openBookUUID) {
        for (NSDictionary *bk in self.books) {
            if ([bk[@"key"] isEqualToString:self.openBookUUID]) {
                self.selectedBook = bk;
                self.openBookUUID = nil;
                break;
            }
        }
    }
    if (self.selectedBook) {
        [self performSegueWithIdentifier:@"bookStatus" sender:self];
    }
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
    NSDictionary *bk = self.books[indexPath.row];

    UIImageView *statusImageView = (UIImageView *)[cell viewWithTag:JGBookCellTagImageView];
    statusImageView.image = [UIImage imageNamed:bk[@"status"]];

    NSDictionary *statusDescription = @{@"topay": @"待付款",
                                        @"toupload": @"待上传",
                                        @"toprint": @"印刷中",
                                        @"shipping": @"已发货",
                                        @"recved": @"已收货"};
    UILabel *bookStatusLabel = (UILabel *)[cell viewWithTag:JGBookCellTagBookStatus];
    bookStatusLabel.text = [NSString stringWithFormat:@"%@（更新于%@）", statusDescription[bk[@"status"]], bk[@"statusUpdated"]];

    UILabel *bookNameLabel = (UILabel *)[cell viewWithTag:JGBookCellTagBookName];
    bookNameLabel.text = bk[@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedBook = self.books[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"bookStatus" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"bookStatus"]) {
        JGSubmitPageViewController *vc = (JGSubmitPageViewController *)segue.destinationViewController;;
        vc.book = [self.selectedBook mutableCopy];
    }
}

@end
