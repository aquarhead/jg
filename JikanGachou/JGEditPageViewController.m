//
//  JGEditPageViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/15/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGEditPageViewController.h"

@interface JGEditPageViewController ()

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
	
//    [self.pageView addSubview:[[[NSBundle mainBundle] loadNibNamed:@"EditPageCover" owner:self options:nil] firstObject]];
}

- (IBAction)pageChanged:(UIPageControl *)sender
{
    CGPoint scrollTo = CGPointMake(kCategoryPageWidth * sender.currentPage, 0);
    [self.categoryView setContentOffset:scrollTo animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = self.categoryView.contentOffset.x / kCategoryPageWidth;
}

#pragma mark Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfPages * self.numberOfIconsInPage;
}

- (void)configureCell:(TYKCategoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TYKCategory *category;
    if (indexPath.row < self.categories.count) {
        category = self.categories[indexPath.row];
    }

    cell.category = category;
    if ([self.selectedCategory isEqual:category]) {
        cell.pressed = YES;
    }
    else {
        cell.pressed = NO;
    }
    cell.label.text = category.name;
    if (category.icon) {
        cell.icon.image = [UIImage imageNamed:category.icon];
    }
    else {
        cell.icon.image = nil;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [self configureCell:(TYKCategoryCell *)cell atIndexPath:indexPath];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    self.selectedCategory = ((TYKCategoryCell *)cell).category;
    [self.categoryView reloadData];
}

@end
