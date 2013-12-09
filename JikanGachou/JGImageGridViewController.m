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

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end

@implementation JGImageGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
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
    [self updateMaskAndCheckViewForCell:cell forPhoto:photoInfo];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSMutableDictionary *photoInfo = self.photos[indexPath.row];

    if ([self.poolViewController hasPhotoInfo:photoInfo]) {
        [self.poolViewController removePhotoInfo:photoInfo];
    } else {
        [self.poolViewController addPhotoInfo:photoInfo];
    }
    
    [self updateMaskAndCheckViewForCell:cell forPhoto:photoInfo];
}

- (void)updateMaskAndCheckViewForCell:(UICollectionViewCell *)cell forPhoto:(NSDictionary *)photoInfo
{
    UIView *maskView = (UIView *)[cell viewWithTag:JGImageGridCellTagMaskView];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:JGImageGridCellTagCheckView];

    if ([self.poolViewController hasPhotoInfo:photoInfo]) {
        maskView.hidden = NO;
        checkView.hidden = NO;
    }
    else {
        maskView.hidden = YES;
        checkView.hidden = YES;
    }
}

@end
