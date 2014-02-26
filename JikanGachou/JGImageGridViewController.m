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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end

@implementation JGImageGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
    self.navigationItem.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nextButton.enabled = [self.poolViewController isValidNumberOfPhotos];
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
        if (![self.poolViewController isUsedPhoto:photo]) {
            [self.poolViewController removePhoto:photo];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这张照片已被使用" message:@"只能撤销未使用的照片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else {
        if (![self.poolViewController poolFull]) {
            [self.poolViewController addPhoto:photo];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"画册放不下更多照片了" message:@"先撤销几张再试试？" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    self.nextButton.enabled = [self.poolViewController isValidNumberOfPhotos];
    
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
