//
//  JGImageGridViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImageGridViewController.h"
#import "JGImagePoolViewController.h"

@interface JGImageGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *gridView;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end

@implementation JGImageGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
    self.navigationItem.title = [self.group valueForProperty:ALAssetsGroupPropertyName];

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

    ALAsset *photo = self.photos[indexPath.row];

    ((UIImageView *)[cell viewWithTag:JGImageGridCellTagImageView]).image = [UIImage imageWithCGImage:photo.thumbnail];
    [self updateMaskAndCheckViewForCell:cell forPhoto:photo];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    ALAsset *photo = self.photos[indexPath.row];

    if ([self.poolViewController hasPhoto:photo]) {
        [self.poolViewController removePhoto:photo];
    } else {
        [self.poolViewController addPhoto:photo];
    }
    
    [self updateMaskAndCheckViewForCell:cell forPhoto:photo];
}

- (void)updateMaskAndCheckViewForCell:(UICollectionViewCell *)cell forPhoto:(ALAsset *)photo
{
    UIView *maskView = (UIView *)[cell viewWithTag:JGImageGridCellTagMaskView];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:JGImageGridCellTagCheckView];

    if ([self.poolViewController hasPhoto:photo]) {
        maskView.hidden = NO;
        checkView.hidden = NO;
    }
    else {
        maskView.hidden = YES;
        checkView.hidden = YES;
    }
}

@end
