//
//  JGImagePickerViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/6/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImageAlbumViewController.h"
#import "JGImageGridViewController.h"
#import "JGImagePoolViewController.h"

@interface JGImageAlbumViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;
@property (nonatomic) NSArray *groups;
@property (nonatomic) NSArray *selectedGroupPhotos;

@end

@implementation JGImageAlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
    NSMutableArray *groups = [NSMutableArray new];
    [self.poolViewController.lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [groups addObject:group];
        }
        else {
            *stop = YES;
            self.groups = [groups copy];
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nextButton.enabled = [self.poolViewController isValidNumberOfPhotos];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

typedef NS_ENUM(NSUInteger, JGImagePickerCellTag) {
    JGImagePickerCellTagImageView = 100,
    JGImagePickerCellTagAlbumName,
    JGImagePickerCellTagAlbumCount
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];

    ((UIImageView *)[cell viewWithTag:JGImagePickerCellTagImageView]).image = [UIImage imageWithCGImage:group.posterImage];
    ((UILabel *)[cell viewWithTag:JGImagePickerCellTagAlbumName]).text = [group valueForProperty:ALAssetsGroupPropertyName];
    ((UILabel *)[cell viewWithTag:JGImagePickerCellTagAlbumCount]).text = [NSString stringWithFormat:@"%ld 张照片", (long)group.numberOfAssets];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlbumToGridSegue"]) {
        JGImageGridViewController *vc = segue.destinationViewController;
        vc.group = self.groups[self.tableView.indexPathForSelectedRow.row];
        vc.photos = self.selectedGroupPhotos;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
    NSMutableArray *photos = [NSMutableArray new];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [photos addObject:result];
        }
        else {
            *stop = YES;
            self.selectedGroupPhotos = [photos copy];
            [self performSegueWithIdentifier:@"AlbumToGridSegue" sender:self];
        }
    }];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
