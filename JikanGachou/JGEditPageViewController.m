//
//  JGEditPageViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/15/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGEditPageViewController.h"
#import "JGImagePoolViewController.h"
#import "JGEditPageCell.h"
#import <NanoStore.h>

static const NSInteger kJGIndexCoverPage = 0;
static const NSInteger kJGIndexFlyleafPage = 1;
static const NSInteger kJGIndexPhotoPageStart = 2; // cover, flyleaf, photos; start from zero.
static const NSInteger kJGIndexBackcoverPage = 22;

@interface JGEditPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, JGImagePoolDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *pagesCollectionView;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;
@property (weak, nonatomic) NSFNanoObject *book;

@end

@implementation JGEditPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController *)self.navigationController).parentViewController;
    self.poolViewController.delegate = self;
    self.book = self.poolViewController.book;
}

- (IBAction)pageChanged:(UIPageControl *)sender
{
    CGPoint scrollTo = CGPointMake(CGRectGetWidth(self.pagesCollectionView.bounds) * sender.currentPage, 0);
    [self.pagesCollectionView setContentOffset:scrollTo animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    self.pageControl.currentPage = self.categoryView.contentOffset.x / kCategoryPageWidth;
}

- (void)didSelectPhoto:(ALAsset *)photoInfo
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSInteger pageIndex = [self.pagesCollectionView indexPathForCell:cell].row;
    if (pageIndex == kJGIndexCoverPage) {
        cell.mainView.firstImageView.image = [UIImage imageWithCGImage:photoInfo.aspectRatioThumbnail];
        
        [self.book setObject:[[photoInfo defaultRepresentation].url query] forKey:@"cover_photo"];
    }
    else if (pageIndex >= kJGIndexPhotoPageStart) {
        [self configureOneLandscape:cell withPhoto:photoInfo];

        NSDictionary *payload = @{@"photo": [[photoInfo defaultRepresentation].url query]};
        [self.book setObject:@{@"payload" : payload, @"type": @"one_landscape"} forKey:[NSString stringWithFormat:@"page%ld", pageIndex-2]
         ];
    }
}

- (void)configureOneLandscape:(JGEditPageCell *)cell withPhoto:(ALAsset *)photoInfo
{
    cell.mainView.firstImageView.image = [UIImage imageWithCGImage:photoInfo.aspectRatioThumbnail];

    NSDate *date = [photoInfo valueForProperty:ALAssetPropertyDate];
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    cell.mainView.firstDateLabel.text = [formatter stringFromDate:date];
}

#pragma mark Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // cover, flyleaf, 20 pages, and backcover
    return 23;
}

- (void)configureCell:(JGEditPageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }

    NSInteger pageIndex = indexPath.row;
    
    if (pageIndex == kJGIndexCoverPage) {
        [cell addViewNamed:@"EditPageCoverTypePhoto"];
        
        if ([self.book objectForKey:@"cover_photo"]) {
            ALAsset *p = [self.poolViewController photoWithQuery:[self.book objectForKey:@"cover_photo"]];
            cell.mainView.firstImageView.image = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
        }
    }
    else if (pageIndex == kJGIndexFlyleafPage) {
        [cell addViewNamed:@"EditPageTitle"];
        if ([self.book objectForKey:@"title"]) {
            // set title
        }
        if ([self.book objectForKey:@"author"]) {
            // set author
        }
    }
    else if (pageIndex == kJGIndexBackcoverPage) {
        [cell addViewNamed:@"EditPageBackCover"];
    }
    else {
        [cell addViewNamed:@"EditPageTypeOneLandscape"];
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", pageIndex-2]];
        if (page) {
            ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            [self configureOneLandscape:cell withPhoto:p];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    JGEditPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

@end
