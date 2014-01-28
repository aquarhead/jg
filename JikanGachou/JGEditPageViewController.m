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

@interface JGEditPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, JGImagePoolDelegate, JGEditPageDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *pagesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewYConstraint;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;
@property (weak, nonatomic) NSFNanoObject *book;
@property (nonatomic) UISegmentedControl *pageTypeControl;

@end

@implementation JGEditPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.poolViewController = (JGImagePoolViewController *)((UINavigationController *)self.navigationController).parentViewController;
    self.poolViewController.delegate = self;
    self.book = self.poolViewController.book;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.pageTypeControl = [[UISegmentedControl alloc] initWithItems:@[@"图标", @"照片"]];
    self.navigationItem.titleView = self.pageTypeControl;
    
    self.pageTypeControl.frame = CGRectMake(0, 0, 130, 30);
    [self.pageTypeControl addTarget:self action:@selector(pageTypeChanged:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)submitClicked:(id)sender {
    [self.poolViewController performSegueWithIdentifier:@"toSubmit" sender:self.poolViewController];
}

#pragma mark - Keyboard related

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    CGFloat keyboardHeightBegin = CGRectGetHeight([userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]);
    CGFloat keyboardHeightEnd = CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    if (keyboardHeightBegin != keyboardHeightEnd) {
        // candidate bar appear / disappear
        return;
    }
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.collectionViewYConstraint.constant += (IS_R4 ? 80 : 120);
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.collectionViewYConstraint.constant -= (IS_R4 ? 80 : 120);
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)collectionViewTouched:(UITapGestureRecognizer *)sender
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    [cell.mainView.titleTextField resignFirstResponder];
    [cell.mainView.authorTextField resignFirstResponder];
}

- (void)saveTitle:(NSString *)title
{
    [self.book setObject:title forKey:@"title"];
}

- (void)saveAuthor:(NSString *)author
{
    [self.book setObject:author forKey:@"author"];
}

#pragma mark - Scroll View

- (IBAction)pageChanged:(UIPageControl *)sender
{
    CGPoint scrollTo = CGPointMake(CGRectGetWidth(self.pagesCollectionView.bounds) * sender.currentPage, 0);
    [self.pagesCollectionView setContentOffset:scrollTo animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    
    if ([self pageIndex] == kJGIndexFlyleafPage) {
        [cell.mainView.titleTextField resignFirstResponder];
        [cell.mainView.authorTextField resignFirstResponder];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    self.pageControl.currentPage = self.categoryView.contentOffset.x / kCategoryPageWidth;
}

#pragma mark - Collection View

- (NSUInteger)pageIndex
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSIndexPath *indexPath = [self.pagesCollectionView indexPathForCell:cell];
    return indexPath.item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // cover, flyleaf, 20 pages, and backcover
    return 23;
}

- (void)pageTypeChanged:(UISegmentedControl *)sender
{
    NSUInteger pageIndex = [self pageIndex];
    if (pageIndex == kJGIndexCoverPage) {
        [self.book setObject:(sender.selectedSegmentIndex == 0 ? @"cover_logo" : @"cover_photo") forKey:@"cover_type"];
    }
    else {
        NSString *type = (sender.selectedSegmentIndex == 0 ? @"one_landscape" : @"two_landscape");
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        NSDictionary *payload = (page ? page[@"payload"] : @{});
        [self.book setObject:@{@"payload": payload, @"type": type} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]
         ];
    }
    
    [self.pagesCollectionView reloadData];
}

- (void)configureCell:(JGEditPageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }

    NSInteger pageIndex = indexPath.item;
    
    if (pageIndex == kJGIndexCoverPage) {
        self.pageTypeControl.hidden = NO;
        [self.pageTypeControl setTitle:@"图标" forSegmentAtIndex:0];
        [self.pageTypeControl setTitle:@"照片" forSegmentAtIndex:1];
        
        if ([[self.book objectForKey:@"cover_type"] isEqualToString:@"cover_photo"]) {
            self.pageTypeControl.selectedSegmentIndex = 1;
            
            [cell addViewNamed:@"EditPageCoverTypePhoto"];
            
            if ([self.book objectForKey:@"cover_photo"]) {
                ALAsset *p = [self.poolViewController photoWithQuery:[self.book objectForKey:@"cover_photo"]];
                ALAssetRepresentation *defaultRepresentation = p.defaultRepresentation;
                cell.mainView.firstImageView.image = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];
            }
        }
        else {
            self.pageTypeControl.selectedSegmentIndex = 0;
            
            [cell addViewNamed:@"EditPageCoverTypeLogo"];
        }
    }
    else if (pageIndex == kJGIndexFlyleafPage) {
        self.pageTypeControl.hidden = YES;
        
        [cell addViewNamed:@"EditPageTitle"];
        cell.mainView.delegate = self;
        if ([self.book objectForKey:@"title"]) {
            cell.mainView.titleTextField.text = [self.book objectForKey:@"title"];
        }
        if ([self.book objectForKey:@"author"]) {
            cell.mainView.authorTextField.text = [self.book objectForKey:@"author"];
        }
    }
    else if (pageIndex == kJGIndexBackcoverPage) {
        [cell addViewNamed:@"EditPageBackCover"];
    }
    else {
        self.pageTypeControl.hidden = NO;
        [self.pageTypeControl setTitle:@"单图" forSegmentAtIndex:0];
        [self.pageTypeControl setTitle:@"双图" forSegmentAtIndex:1];
        
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        
        if (!page || [page[@"type"] isEqualToString:@"one_landscape"]) {
            self.pageTypeControl.selectedSegmentIndex = 0;
            
            [cell addViewNamed:@"EditPageTypeOneLandscape"];
        }
        else {
            self.pageTypeControl.selectedSegmentIndex = 1;
            
            [cell addViewNamed:@"EditPageTypeTwoLandscape"];
        }
        
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

#pragma mark - poolView delegate

- (void)didSelectPhoto:(ALAsset *)photoInfo
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSInteger pageIndex = [self.pagesCollectionView indexPathForCell:cell].row;
    if (pageIndex == kJGIndexCoverPage) {
        ALAssetRepresentation *defaultRepresentation = photoInfo.defaultRepresentation;
        cell.mainView.firstImageView.image = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];

        [self.book setObject:[photoInfo.defaultRepresentation.url query] forKey:@"cover_photo"];
    }
    else if (pageIndex >= kJGIndexPhotoPageStart) {
        [self configureOneLandscape:cell withPhoto:photoInfo];
        [self.poolViewController usePhoto:photoInfo];

        NSDictionary *payload = @{@"photo": [photoInfo.defaultRepresentation.url query]};
        [self.book setObject:@{@"payload": payload, @"type": @"one_landscape"} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]
         ];
    }
}

- (void)configureOneLandscape:(JGEditPageCell *)cell withPhoto:(ALAsset *)photoInfo
{
    ALAssetRepresentation *defaultRepresentation = photoInfo.defaultRepresentation;
    cell.mainView.firstImageView.image = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];

    NSDate *date = [photoInfo valueForProperty:ALAssetPropertyDate];
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    cell.mainView.firstDateLabel.text = [formatter stringFromDate:date];
}

@end
