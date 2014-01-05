//
//  JGImagePoolViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePoolViewController.h"

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;
@property (nonatomic) NSMutableArray *selectedPhotos;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedPhotos = [NSMutableArray new];
    self.lib = [ALAssetsLibrary new];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    ALAsset *asset = self.selectedPhotos[indexPath.row];
    ((UIImageView *)[cell viewWithTag:100]).image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

    return cell;
}

- (void)reload
{
    [self.collectionView reloadData];
    self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", (unsigned)self.selectedPhotos.count];
    
    if (self.selectedPhotos.count > 0) {
        self.placeholderView.hidden = YES;
    }
    else {
        self.placeholderView.hidden = NO;
    }
}

- (void)addPhoto:(ALAsset *)photo
{
    [self.selectedPhotos addObject:photo];
    [self reload];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPhotos.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removePhoto:(ALAsset *)photo
{
    [self.selectedPhotos removeObject:photo];
    [self.selectedPhotos enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *p, NSUInteger index, BOOL *stop) {
        if ([[p valueForProperty:ALAssetPropertyAssetURL] isEqual:[photo valueForProperty:ALAssetPropertyAssetURL]]) {
            [self.selectedPhotos removeObjectAtIndex:index];
        }
    }];
    [self reload];
}

- (BOOL)hasPhoto:(ALAsset *)photo
{
    for (ALAsset *p in self.selectedPhotos) {
        if ([[p valueForProperty:ALAssetPropertyAssetURL] isEqual:[photo valueForProperty:ALAssetPropertyAssetURL]]) {
            return true;
        }
    }
    return false;
}

- (BOOL)isValidNumberOfPhotos
{
    return (self.selectedPhotos.count >= 20) && (self.selectedPhotos.count <= 40);
}

@end
