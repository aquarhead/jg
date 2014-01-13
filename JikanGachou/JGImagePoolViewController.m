//
//  JGImagePoolViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePoolViewController.h"

#ifdef DEBUG
const NSUInteger kJGPoolLeastPhotos = 2;
const NSUInteger kJGPoolMostPhotos  = 2;
#else
const NSUInteger kJGPoolLeastPhotos = 20;
const NSUInteger kJGPoolMostPhotos  = 20;
#endif

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;

@property (nonatomic) NSFNanoStore *store;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedPhotos = [NSMutableArray new];
    self.lib = [ALAssetsLibrary new];

    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:@"store.sqlite"];
    NSError *outError = nil;
    self.store = [NSFNanoStore createAndOpenStoreWithType:NSFPersistentStoreType path:path error:&outError];
    self.book = [NSFNanoObject new];
    [self.book setObject:@"logo" forKey:@"cover_type"];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectPhoto:)]) {
        [self.delegate didSelectPhoto:self.selectedPhotos[indexPath.row]];
    }
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

- (ALAsset *)photoWithQuery:(NSString *)query
{
    for (ALAsset *p in self.selectedPhotos) {
        if ([[[p defaultRepresentation].url query] isEqualToString:query]) {
            return p;
        }
    }
    return nil;
}

- (BOOL)isValidNumberOfPhotos
{
    return (self.selectedPhotos.count >= kJGPoolLeastPhotos) && (self.selectedPhotos.count <= kJGPoolMostPhotos);
}

- (BOOL)poolFull
{
    return (self.selectedPhotos.count == kJGPoolMostPhotos);
}

@end
