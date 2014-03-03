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
#import <NSMutableArray+Shuffle.h>

#ifdef DEBUG
const NSUInteger kJGPoolLeastPhotos = 1;
#else
const NSUInteger kJGPoolLeastPhotos = 20;
#endif
const NSUInteger kJGPoolMostPhotos  = 40;

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *placeholderButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

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
    self.book[@"key"] = [[NSUUID UUID] UUIDString];
}

#pragma mark - Function Switch

- (void)switchToPool
{
    self.barView.hidden = NO;
    self.collectionView.hidden = NO;
    self.shuffleButton.hidden = YES;
    [self reload];
}

- (void)switchToShuffleButton
{
    self.barView.hidden = YES;
    self.collectionView.hidden = YES;
    self.placeholderButton.hidden = YES;
    self.shuffleButton.hidden = NO;
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedPhotos.count;
}

- (UIImage *)imageWithBorderFromImage:(UIImage *)source;
{
    CGSize size = [source size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextSetLineWidth(context, 5);
    CGContextStrokeRect(context, rect);
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ALAsset *asset = self.selectedPhotos[indexPath.row];

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = [self imageWithBorderFromImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectPhoto:)]) {
        [self.delegate didSelectPhoto:self.selectedPhotos[indexPath.row]];
        [self reload];
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
    if (used_count > 0) {
        self.selectedCountLabel.text = [NSString stringWithFormat:@"已用 %u / %u 张", (unsigned)used_count, (unsigned)count];
    } else {
        self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", (unsigned)count];
    }
    if (self.selectedPhotos.count > 0) {
        self.placeholderButton.hidden = YES;
    } else {
        self.placeholderButton.hidden = NO;
    }
}

- (IBAction)shufflePressed:(UIButton *)sender
{
    if ([self.shuffleDelegate respondsToSelector:@selector(shuffledPhotos:)]) {
        [self.usedPhotos shuffle];
        [self.shuffleDelegate shuffledPhotos:[self.usedPhotos copy]];
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

- (void)saveBookAndExit
{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy MM dd";
    }
    for (int i=0; i<20; i++) {
        NSString *pageKey = [NSString stringWithFormat:@"page%d", i];
        NSMutableDictionary *page = [self.book[pageKey] mutableCopy];
        NSDictionary *pageTypeMapping = @{@"EditPageTypeOneLandscape": @"h",
                                          @"EditPageTypeOnePortrait": @"v",
                                          @"EditPageTypeTwoLandscape": @"hh",
                                          @"EditPageTypeMixedLeftLandscape": @"hv",
                                          @"EditPageTypeMixedLeftPortrait": @"vh",
                                          @"EditPageTypeTwoPortrait": @"vv"};
        if (page) {
            if (page[@"photo"]) {
                ALAsset *p = [self photoWithURLString:page[@"photo"]];
                NSDate *date = [p valueForProperty:ALAssetPropertyDate];
                page[@"date"] = [formatter stringFromDate:date];
                page[@"photo_name"] = [NSString stringWithFormat:@"%@.JPG", [[NSURL URLWithString:page[@"photo"]] query]];
            }
            if (page[@"type"] && ![page[@"type"] hasPrefix:@"EditPageTypeOne"] && page[@"photo2"]) {
                ALAsset *p = [self photoWithURLString:page[@"photo2"]];
                NSDate *date = [p valueForProperty:ALAssetPropertyDate];
                page[@"date2"] = [formatter stringFromDate:date];
                page[@"photo2_name"] = [NSString stringWithFormat:@"%@.JPG", [[NSURL URLWithString:page[@"photo2"]] query]];
            }
            page[@"type_class"] = pageTypeMapping[page[@"type"]];
            self.book[pageKey] = [page copy];
        }
    }
    for (int i = 0; i < MIN(9, self.usedPhotos.count); ++i) {
        NSURL *url = [NSURL URLWithString:self.book[[NSString stringWithFormat:@"cover%d", i+1]]];
        self.book[[NSString stringWithFormat:@"cover%d_name", i+1]] = [NSString stringWithFormat:@"%@.JPG", [url query]];
    }
    self.book[@"status"] = @"topay";
    static NSDateFormatter *updatedFormatter;
    if (!updatedFormatter) {
        updatedFormatter = [NSDateFormatter new];
        updatedFormatter.dateFormat = @"yyyy年MM月dd日";
    }
    self.book[@"statusUpdated"] = [updatedFormatter stringFromDate:[NSDate date]];
    NyaruDB *db = [NyaruDB instance];
    NyaruCollection *collection = [db collection:@"books"];
    [collection put:[self.book copy]];
    [collection waitForWriting];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.homeVC openWithBookUUID:self.book[@"key"]];
    }];
}

@end
