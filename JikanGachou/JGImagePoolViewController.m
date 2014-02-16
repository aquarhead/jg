//
//  JGImagePoolViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePoolViewController.h"
#import "JGSubmitPageViewController.h"
#import <NyaruDB.h>

#ifdef DEBUG
const NSUInteger kJGPoolLeastPhotos = 1;
#else
const NSUInteger kJGPoolLeastPhotos = 20;
#endif
const NSUInteger kJGPoolMostPhotos  = 40;

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *placeholderButton;

@property (nonatomic) NSMutableArray *selectedPhotos;
@property (nonatomic) NSMutableArray *usedPhotos;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedPhotos = [NSMutableArray new];
    self.usedPhotos = [NSMutableArray new];
    self.lib = [ALAssetsLibrary new];
    self.book = [NSMutableDictionary new];
    self.book[@"cover_type"] = @"EditPageCoverTypeLogo";
    self.book[@"key"] = [[NSUUID UUID] UUIDString];
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
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.4
                         animations:^{
                             cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y - 64, cell.frame.size.width, cell.frame.size.height);
                         } completion:^(BOOL finished) {
                             [self.delegate didSelectPhoto:self.selectedPhotos[indexPath.row]];
                             [self reload];
                         }];
    }
}

- (IBAction)placeholderPressed:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didTapPlaceholder)]) {
        [self.delegate didTapPlaceholder];
    }
}

- (void)reload
{
    [self.collectionView reloadData];
    NSUInteger count = self.selectedPhotos.count + self.usedPhotos.count;
    NSUInteger used_count = self.usedPhotos.count;
    if ([[self.book objectForKey:@"cover_type"] isEqualToString:@"EditPageCoverTypePhoto"]
        && [self.book objectForKey:@"cover_photo"]
        && ![self.usedPhotos containsObject:[self photoWithURLString:[self.book objectForKey:@"cover_photo"]]]) {
        used_count += 1;
    }
    if (used_count > 0) {
        self.selectedCountLabel.text = [NSString stringWithFormat:@"已用 %u / %u 张", (unsigned)used_count, (unsigned)count];
    } else {
        self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", (unsigned)count];
    }
    if (self.selectedPhotos.count > 0) {
        self.placeholderButton.hidden = YES;
    }
    else {
        self.placeholderButton.hidden = NO;
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
    [self.selectedPhotos removeObject:[self photoWithURLString:[photo.defaultRepresentation.url absoluteString]]];
    [self reload];
}

- (BOOL)hasPhoto:(ALAsset *)photo
{
    NSMutableArray *photos = [NSMutableArray new];
    [photos addObjectsFromArray:self.selectedPhotos];
    [photos addObjectsFromArray:self.usedPhotos];
    for (ALAsset *p in photos) {
        if ([p.defaultRepresentation.url isEqual:photo.defaultRepresentation.url]) {
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
    if ([[self.book objectForKey:@"cover_type"] isEqualToString:@"EditPageCoverTypePhoto"]
        && [photo isEqual:[self photoWithURLString:[self.book objectForKey:@"cover_photo"]]]) {
        return YES;
    }
    return [self.usedPhotos containsObject:photo];
}

- (ALAsset *)photoWithURLString:(NSString *)urlstr
{
    NSMutableArray *photos = [NSMutableArray new];
    [photos addObjectsFromArray:self.selectedPhotos];
    [photos addObjectsFromArray:self.usedPhotos];
    for (ALAsset *p in photos) {
        if ([p.defaultRepresentation.url isEqual:[NSURL URLWithString:urlstr]]) {
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
        JGSubmitPageViewController *vc = (JGSubmitPageViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        vc.book = [self.book copy];
        NyaruDB *db = [NyaruDB instance];
        NyaruCollection *collection = [db collection:@"books"];
        [collection put:[self.book copy]];
        [collection waitForWriting];
    }
}

@end
