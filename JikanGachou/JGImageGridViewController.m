//
//  JGImageGridViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImageGridViewController.h"
#import "JGImagePoolViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface JGImageGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *gridView;

@property (nonatomic) NSArray *photos;
@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end

@implementation JGImageGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib groupForURL:[self.groupInfo objectForKey:@"url"] resultBlock:^(ALAssetsGroup *group) {
        NSMutableArray *photos = [NSMutableArray new];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                NSMutableDictionary *photoInfo = [NSMutableDictionary new];
                [photoInfo setObject:[result valueForProperty:ALAssetPropertyAssetURL] forKey:@"url"];
                [photoInfo setObject:[UIImage imageWithCGImage:[result thumbnail]] forKey:@"image"];
                [photos addObject:[photoInfo copy]];
            }
            else {
                *stop = YES;
                self.photos = [photos copy];
                [self.gridView reloadData];
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    self.navigationItem.title = [self.groupInfo objectForKey:@"name"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

typedef NS_ENUM(NSUInteger, JGImageGridCellTag) {
    JGImageGridCellTagImageView = 100,
    JGImageGridCellTagMaskView,
    JGImageGridCellTagCheckView,
};

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *photoInfo = self.photos[indexPath.row];

    ((UIImageView *)[cell viewWithTag:JGImageGridCellTagImageView]).image = photoInfo[@"image"];
    ((UIView *)[cell viewWithTag:JGImageGridCellTagMaskView]).hidden = YES;
    ((UIImageView *)[cell viewWithTag:JGImageGridCellTagCheckView]).hidden = YES;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *maskView = (UIView *)[cell viewWithTag:JGImageGridCellTagMaskView];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:JGImageGridCellTagCheckView];
    
    NSDictionary *photoInfo = self.photos[indexPath.row];
    
    if (maskView.hidden) {
        // not selected
        [self.poolViewController addPhotoInfo:photoInfo];
        
        maskView.hidden = NO;
        checkView.hidden = NO;
    }
    else {
        // selected
        [self.poolViewController removePhotoInfo:photoInfo];
        
        maskView.hidden = YES;
        checkView.hidden = YES;
    }
}

@end
