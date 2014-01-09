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

@interface JGEditPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, JGImagePoolDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *pagesCollectionView;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

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
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController*)self.navigationController).parentViewController;
    self.poolViewController.delegate = self;
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
    [self.pagesCollectionView.visibleCells firstObject];
}

#pragma mark Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // cover, flyleaf, and photos
    return 1 + 1 + self.poolViewController.selectedPhotos.count;
}

- (void)configureCell:(JGEditPageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        [cell addViewNamed:@"EditPageCoverTypeLogo"];
    }
    else if (indexPath.row == 1) {
        [cell addViewNamed:@"EditPageTitle"];
    }
    else {
        [cell addViewNamed:@"EditPageTypeOneLandscape"];
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
