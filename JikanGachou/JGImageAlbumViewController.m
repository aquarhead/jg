//
//  JGImagePickerViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/6/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImageAlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface JGImageAlbumViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *albums;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JGImageAlbumViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

typedef NS_ENUM(NSUInteger, JGImagePickerCellTag) {
    JGImagePickerCellTagImageView = 100,
    JGImagePickerCellTagAlbumName,
    JGImagePickerCellTagAlbumCount
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *groupInfo = [self.albums objectAtIndex:indexPath.row];

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
            [groupInfo setObject:[group valueForProperty:ALAssetsGroupPropertyURL] forKey:@"url"];
            [groupInfo setObject:[UIImage imageWithCGImage:[group posterImage]] forKey:@"posterImage"];
            [groupInfo setObject:[group valueForProperty:ALAssetsGroupPropertyName] forKey:@"name"];
            [groupInfo setObject:[NSString stringWithFormat:@"%d", [group numberOfAssets]] forKey:@"numberOfAssets"];
            [albums addObject:[groupInfo copy]];
        } else {
            *stop = YES;
            self.albums = [albums copy];
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
