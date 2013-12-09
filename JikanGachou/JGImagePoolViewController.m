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
@property (nonatomic) NSMutableArray *selectedPhotoInfos;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedPhotoInfos = [NSMutableArray new];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedPhotoInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    ((UIImageView *)[cell viewWithTag:100]).image = self.selectedPhotoInfos[indexPath.row][@"image"];

    return cell;
}

- (void)reload
{
    [self.collectionView reloadData];
    self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", (unsigned)self.selectedPhotoInfos.count];
    
    if (self.selectedPhotoInfos.count > 0) {
        self.placeholderView.hidden = YES;
    }
    else {
        self.placeholderView.hidden = NO;
    }
}

- (void)addPhotoInfo:(NSDictionary *)photoInfo
{
    [self.selectedPhotoInfos addObject:photoInfo];
    
    [self reload];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPhotoInfos.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removePhotoInfo:(NSDictionary *)photoInfo
{
    NSDictionary *infoToRemove;
    for (NSDictionary *info in self.selectedPhotoInfos) {
        if ([info[@"url"] isEqual:photoInfo[@"url"]]) {
            infoToRemove = info;
            break;
        }
    }
    [self.selectedPhotoInfos removeObject:infoToRemove];
    
    [self reload];
}

- (BOOL)hasPhotoInfo:(NSDictionary *)photoInfo
{
    for (NSDictionary *info in self.selectedPhotoInfos) {
        if ([info[@"url"] isEqual:photoInfo[@"url"]]) {
            return YES;
        }
    }
    return NO;
}

@end
