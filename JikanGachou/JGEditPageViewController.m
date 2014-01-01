//
//  JGEditPageViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/15/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGEditPageViewController.h"

@interface JGEditPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *pagesCollectionView;

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

#pragma mark Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        [cell addSubview:[[[NSBundle mainBundle] loadNibNamed:@"EditPageCoverTypeLogo" owner:self options:nil] firstObject]];
    }
    else if (indexPath.row == 1) {
        [cell addSubview:[[[NSBundle mainBundle] loadNibNamed:@"EditPageTitle" owner:self options:nil] firstObject]];
    }
    else {
        [cell addSubview:[[[NSBundle mainBundle] loadNibNamed:@"EditPageTypeOneLandscape" owner:self options:nil] firstObject]];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

@end
