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

@property (nonatomic) UITapGestureRecognizer *tapRecog;

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

    self.tapRecog = [UITapGestureRecognizer new];
    [self.tapRecog addTarget:self action:@selector(handleTap:)];
    self.tapRecog.numberOfTapsRequired = 1;
    self.tapRecog.numberOfTouchesRequired = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.pageTypeControl = [[UISegmentedControl alloc] initWithItems:@[@"图标", @"照片"]];
    self.navigationItem.titleView = self.pageTypeControl;
    
    self.pageTypeControl.frame = CGRectMake(0, 0, 130, 30);
    [self.pageTypeControl addTarget:self action:@selector(pageTypeChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Segue

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
    if ([self pageIndex] == kJGIndexFlyleafPage) {
        JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
        [cell.mainView.titleTextField resignFirstResponder];
        [cell.mainView.authorTextField resignFirstResponder];
    }
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
        [self.book setObject:(sender.selectedSegmentIndex == 0 ? @"EditPageCoverTypeLogo" : @"EditPageCoverTypePhoto") forKey:@"cover_type"];
    }
    else {
        NSString *type = (sender.selectedSegmentIndex == 0 ? @"EditPageTypeOneLandscape" : @"EditPageTypeTwoLandscape");
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        NSDictionary *payload = (page ? page[@"payload"] : @{});
        [self.book setObject:@{@"payload": payload, @"type": type} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
    }
    
    [self.pagesCollectionView reloadData];
}

- (void)setupCell:(JGEditPageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger pageIndex = indexPath.item;
    
    if (pageIndex == kJGIndexCoverPage) {
        [self.pageTypeControl setTitle:@"图标" forSegmentAtIndex:0];
        [self.pageTypeControl setTitle:@"照片" forSegmentAtIndex:1];
        
        if ([[self.book objectForKey:@"cover_type"] isEqualToString:@"EditPageCoverTypePhoto"]) {
            self.pageTypeControl.selectedSegmentIndex = 1;
            
            [cell useMainViewNamed:@"EditPageCoverTypePhoto" withGestureRecognizer:self.tapRecog];
            
            if ([self.book objectForKey:@"cover_photo"]) {
                ALAsset *p = [self.poolViewController photoWithQuery:[self.book objectForKey:@"cover_photo"]];
                ALAssetRepresentation *defaultRepresentation = p.defaultRepresentation;
                cell.mainView.firstImageView.image = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];
            }
        }
        else {
            self.pageTypeControl.selectedSegmentIndex = 0;
            
            [cell useMainViewNamed:@"EditPageCoverTypeLogo" withGestureRecognizer:self.tapRecog];
        }
    }
    else if (pageIndex == kJGIndexFlyleafPage) {
        self.pageTypeControl.hidden = YES;
        
        [cell useMainViewNamed:@"EditPageTitle" withGestureRecognizer:self.tapRecog];
        cell.mainView.delegate = self;
        if ([self.book objectForKey:@"title"]) {
            cell.mainView.titleTextField.text = [self.book objectForKey:@"title"];
        }
        if ([self.book objectForKey:@"author"]) {
            cell.mainView.authorTextField.text = [self.book objectForKey:@"author"];
        }
    }
    else if (pageIndex == kJGIndexBackcoverPage) {
        self.pageTypeControl.hidden = YES;
        
        [cell useMainViewNamed:@"EditPageBackCover" withGestureRecognizer:self.tapRecog];
    }
    else {
        [self.pageTypeControl setTitle:@"单图" forSegmentAtIndex:0];
        [self.pageTypeControl setTitle:@"双图" forSegmentAtIndex:1];
        
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        if (!page) {
            page = @{@"payload": @{}, @"type": @"EditPageTypeOneLandscape"};
            [self.book setObject:page forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        }
        
        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            self.pageTypeControl.selectedSegmentIndex = 0;
            
            [cell useMainViewNamed:page[@"type"] withGestureRecognizer:self.tapRecog];
        }
        else {
            self.pageTypeControl.selectedSegmentIndex = 1;
            
            [cell useMainViewNamed:page[@"type"] withGestureRecognizer:self.tapRecog];
        }
        
        if (page) {
            ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            [self setPhoto:p andType:page[@"type"] forCell:cell];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
        NSIndexPath *indexPath = [self.pagesCollectionView indexPathForCell:cell];
        NSInteger pageIndex = indexPath.item;
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
        if (page) {
            ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            if (p) {
                [self.poolViewController dropPhoto:p];
            }
            [self.book setObject:@{@"payload": @{@"photo": @""}, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];
            [self setPhoto:nil andType:nil forCell:cell];
        }
    }
}

- (void)setPhoto:(ALAsset *)photoInfo andType:(NSString *)type forCell:(JGEditPageCell *)cell
{
    if (photoInfo) {
        ALAssetRepresentation *defaultRepresentation = photoInfo.defaultRepresentation;
        UIImage *img = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];
        CGSize size = img.size;
        if (size.width >= size.height) {
            if ([type hasPrefix:@"EditPageTypeOne"]) {
                [cell useMainViewNamed:@"EditPageTypeOneLandscape" withGestureRecognizer:self.tapRecog];
            }
            else {
                [cell useMainViewNamed:@"EditPageTypeMixedLeftLandscape" withGestureRecognizer:self.tapRecog];
            }
        }
        else {
            if ([type hasPrefix:@"EditPageTypeOne"]) {
                [cell useMainViewNamed:@"EditPageTypeOnePortrait" withGestureRecognizer:self.tapRecog];
            }
            else {
                [cell useMainViewNamed:@"EditPageTypeMixedLeftPortrait" withGestureRecognizer:self.tapRecog];
            }
        }
        
        cell.mainView.firstImageView.image = img;

        NSDate *date = [photoInfo valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *formatter;
        if (!formatter) {
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
        }
        cell.mainView.firstDateLabel.text = [formatter stringFromDate:date];
    } else {
        cell.mainView.firstImageView.image = nil;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    JGEditPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [self setupCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger pageIndex = indexPath.item;
    
    if (pageIndex == kJGIndexFlyleafPage) {
        self.pageTypeControl.hidden = NO;
    }
    else if (pageIndex == kJGIndexBackcoverPage) {
        self.pageTypeControl.hidden = NO;
    }
}

#pragma mark - poolView delegate

- (void)didSelectPhoto:(ALAsset *)photoInfo
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSInteger pageIndex = [self.pagesCollectionView indexPathForCell:cell].row;
    if (pageIndex == kJGIndexCoverPage) {
        if (self.pageTypeControl.selectedSegmentIndex == 1) {
            ALAssetRepresentation *defaultRepresentation = photoInfo.defaultRepresentation;
            cell.mainView.firstImageView.image = [UIImage imageWithCGImage:defaultRepresentation.fullScreenImage];
            
            [self.book setObject:[photoInfo.defaultRepresentation.url query] forKey:@"cover_photo"];
        }
    }
    else if (pageIndex >= kJGIndexPhotoPageStart) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]];

        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            if (page[@"payload"][@"photo"] && ![page[@"payload"][@"photo"] isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这一页放不下更多照片了" message:@"试试点击书中的照片来撤销" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self setPhoto:photoInfo andType:page[@"type"] forCell:cell];
                [self.poolViewController usePhoto:photoInfo];
                NSDictionary *payload = @{@"photo": [photoInfo.defaultRepresentation.url query]};
                [self.book setObject:@{@"payload": payload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-2]
                 ];
            }
        }

    }
}

@end
