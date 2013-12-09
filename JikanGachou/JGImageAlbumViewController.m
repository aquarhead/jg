//
//  JGImagePickerViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/6/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImageAlbumViewController.h"
#import "JGImageGridViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface JGImageAlbumViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *groups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *selectedGroupPhotos;

@end

@implementation JGImageAlbumViewController

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

    NSDictionary *groupInfo = [self.groups objectAtIndex:indexPath.row];

    ((UIImageView *)[cell viewWithTag:JGImagePickerCellTagImageView]).image = [groupInfo objectForKey:@"posterImage"];
    ((UILabel *)[cell viewWithTag:JGImagePickerCellTagAlbumName]).text = [groupInfo objectForKey:@"name"];
    ((UILabel *)[cell viewWithTag:JGImagePickerCellTagAlbumCount]).text = [NSString stringWithFormat:@"%@ 张照片", [groupInfo objectForKey:@"numberOfAssets"]];

    return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    NSMutableArray *albums = [NSMutableArray new];
    [lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSMutableDictionary *groupInfo = [NSMutableDictionary new];
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            groupInfo[@"url"] = [group valueForProperty:ALAssetsGroupPropertyURL];
            groupInfo[@"posterImage"] = [UIImage imageWithCGImage:[group posterImage]];
            groupInfo[@"name"] = [group valueForProperty:ALAssetsGroupPropertyName];
            groupInfo[@"numberOfAssets"] = [NSString stringWithFormat:@"%ld", (long)[group numberOfAssets]];

            [albums addObject:[groupInfo copy]];
        }
        else {
            *stop = YES;
            self.groups = [albums copy];
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlbumToGridSegue"]) {
        JGImageGridViewController *vc = segue.destinationViewController;
        vc.groupInfo = self.groups[self.tableView.indexPathForSelectedRow.row];
        vc.photos = self.selectedGroupPhotos;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib groupForURL:self.groups[indexPath.row][@"url"] resultBlock:^(ALAssetsGroup *group) {
        NSMutableArray *photos = [NSMutableArray new];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                NSMutableDictionary *photoInfo = [NSMutableDictionary new];
                photoInfo[@"url"] = [result valueForProperty:ALAssetPropertyAssetURL];
                photoInfo[@"image"] = [UIImage imageWithCGImage:[result thumbnail]];
                [photos addObject:photoInfo];
            }
            else {
                *stop = YES;
                self.selectedGroupPhotos = [photos copy];
                [self performSegueWithIdentifier:@"AlbumToGridSegue" sender:self];
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
