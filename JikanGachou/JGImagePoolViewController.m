//
//  JGImagePoolViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePoolViewController.h"
#import "JGSubmitPageViewController.h"

#ifdef DEBUG
const NSUInteger kJGPoolLeastPhotos = 1;
#else
const NSUInteger kJGPoolLeastPhotos = 20;
#endif
const NSUInteger kJGPoolMostPhotos  = 40;

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;

@property (nonatomic) NSMutableArray *selectedPhotos;
@property (nonatomic) NSMutableArray *usedPhotos;

@property (nonatomic) NSFNanoStore *store;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedPhotos = [NSMutableArray new];
    self.usedPhotos = [NSMutableArray new];
    self.lib = [ALAssetsLibrary new];

    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:@"store.sqlite"];
    NSError *outError = nil;
    self.store = [NSFNanoStore createAndOpenStoreWithType:NSFPersistentStoreType path:path error:&outError];
    self.book = [NSFNanoObject new];
    [self.book setObject:@"photo" forKey:@"cover_type"];
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
    NSUInteger count = self.selectedPhotos.count + self.usedPhotos.count;
    self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", (unsigned)count];
    
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
    [self reload];
}

- (BOOL)hasPhoto:(ALAsset *)photo
{
    NSMutableArray *photos = [NSMutableArray new];
    [photos addObjectsFromArray:self.selectedPhotos];
    [photos addObjectsFromArray:self.usedPhotos];
    for (ALAsset *p in photos) {
        if ([p isEqual:photo]) {
            return true;
        }
    }
    return false;
}

- (void)usePhoto:(ALAsset *)photo
{
    [self.selectedPhotos removeObject:photo];
    [self.usedPhotos addObject:photo];
    [self reload];
}

- (void)dropPhoto:(ALAsset *)photo
{
    [self.usedPhotos removeObject:photo];
    [self.selectedPhotos addObject:photo];
    [self reload];
}

- (BOOL)isUsedPhoto:(ALAsset *)photo
{
    for (ALAsset *p in self.usedPhotos) {
        if ([p isEqual:photo]) {
            return true;
        }
    }
    return false;
}

- (ALAsset *)photoWithQuery:(NSString *)query
{
    NSMutableArray *photos = [NSMutableArray new];
    [photos addObjectsFromArray:self.selectedPhotos];
    [photos addObjectsFromArray:self.usedPhotos];
    for (ALAsset *p in photos) {
        if ([[[p defaultRepresentation].url query] isEqualToString:query]) {
            return p;
        }
    }
    return nil;
}

- (BOOL)isValidNumberOfPhotos
{
    NSUInteger count = self.selectedPhotos.count + self.usedPhotos.count;
    return (count >= kJGPoolLeastPhotos) && (count <= kJGPoolMostPhotos);
}

- (BOOL)poolFull
{
    NSUInteger count = self.selectedPhotos.count + self.usedPhotos.count;
    return (count == kJGPoolMostPhotos);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSubmit"]) {
        JGSubmitPageViewController *vc = segue.destinationViewController;
        vc.photos = [self.usedPhotos copy];
        vc.poolViewController = self;
        [self.store saveStoreAndReturnError:nil];
    }
}

@end
