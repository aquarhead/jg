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

@property (nonatomic) NSArray *tapRecogs;

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

    UITapGestureRecognizer *tapRecog = [UITapGestureRecognizer new];
    [tapRecog addTarget:self action:@selector(handleTap:)];
    tapRecog.numberOfTapsRequired = 1;
    tapRecog.numberOfTouchesRequired = 1;

    UITapGestureRecognizer *tapRecog2 = [UITapGestureRecognizer new];
    [tapRecog2 addTarget:self action:@selector(handleTap:)];
    tapRecog2.numberOfTapsRequired = 1;
    tapRecog2.numberOfTouchesRequired = 1;

    self.tapRecogs = @[tapRecog, tapRecog2];
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
    NSString *errmsg = nil;
    NSIndexPath *idxp = nil;
    // check 20 pages
    for (int pageIndex=0; pageIndex<20; pageIndex++) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%d", pageIndex]];
        if (!page
            || !page[@"payload"][@"photo"]
            || (![page[@"type"] hasPrefix:@"EditPageTypeOne"] && !page[@"payload"][@"photo2"])) {
            errmsg = @"请选择想打印的照片";
            idxp = [NSIndexPath indexPathForItem:pageIndex+kJGIndexPhotoPageStart inSection:0];
            break;
        }
    }
    // check title and author
    if (![self.book objectForKey:@"author"]
        || [[self.book objectForKey:@"author"] isEqualToString:@""]) {
        errmsg = @"请填写作者";
        idxp = [NSIndexPath indexPathForItem:kJGIndexFlyleafPage inSection:0];
    }
    if (![self.book objectForKey:@"title"]
        || [[self.book objectForKey:@"title"] isEqualToString:@""]) {
        errmsg = @"请填写相册名";
        idxp = [NSIndexPath indexPathForItem:kJGIndexFlyleafPage inSection:0];
    }
    // check cover_photo
    if ([[self.book objectForKey:@"cover_type"] hasSuffix:@"Photo"]) {
        if (![self.book objectForKey:@"cover_photo"]
            || [[self.book objectForKey:@"cover_photo"] isEqualToString:@""]) {
            errmsg = @"请设置用于相册封面的照片";
            idxp = [NSIndexPath indexPathForItem:kJGIndexCoverPage inSection:0];
        }
    }
    if (errmsg) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相册不完整" message:errmsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.pagesCollectionView scrollToItemAtIndexPath:idxp atScrollPosition:0 animated:YES];
    } else {
        [self.poolViewController performSegueWithIdentifier:@"toSubmit" sender:self.poolViewController];
    }
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
    [self.pagesCollectionView reloadData];
}

#pragma mark - Collection View

- (NSUInteger)pageIndex
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSIndexPath *indexPath = [self.pagesCollectionView indexPathForCell:cell];
    return indexPath.item;
}

- (NSIndexPath *)pageIndexPath
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSIndexPath *indexPath = [self.pagesCollectionView indexPathForCell:cell];
    return indexPath;
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
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        if (page) {
            if ([page[@"type"] hasPrefix:@"EditPageTypeTwo"] || [page[@"type"] hasPrefix:@"EditPageTypeMixed"]) {
                // drop photo2
                ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo2"]];
                if (p) {
                    [self.poolViewController dropPhoto:p];
                }
                NSMutableDictionary *newpayload = [NSMutableDictionary dictionaryWithDictionary:page[@"payload"]];
                newpayload[@"photo2"] = @"";
                [self.book setObject:@{@"payload": newpayload, @"type": type} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
            } else {
                [self.book setObject:@{@"payload": page[@"payload"], @"type": type} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
            }
        }
        else {
            [self.book setObject:@{@"payload": @{}, @"type": type} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        }
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

            [cell useMainViewNamed:@"EditPageCoverTypePhoto" withGestureRecognizers:self.tapRecogs];

            if ([self.book objectForKey:@"cover_photo"]) {
                ALAsset *p = [self.poolViewController photoWithQuery:[self.book objectForKey:@"cover_photo"]];
                [cell.mainView fillNth:1 withPhoto:p];
            }
        }
        else {
            self.pageTypeControl.selectedSegmentIndex = 0;

            [cell useMainViewNamed:@"EditPageCoverTypeLogo" withGestureRecognizers:self.tapRecogs];
        }
    }
    else if (pageIndex == kJGIndexFlyleafPage) {
        self.pageTypeControl.hidden = YES;

        [cell useMainViewNamed:@"EditPageTitle" withGestureRecognizers:self.tapRecogs];
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

        [cell useMainViewNamed:@"EditPageBackCover" withGestureRecognizers:self.tapRecogs];
    }
    else {
        [self.pageTypeControl setTitle:@"单图" forSegmentAtIndex:0];
        [self.pageTypeControl setTitle:@"双图" forSegmentAtIndex:1];

        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        if (!page) {
            page = @{@"payload": @{}, @"type": @"EditPageTypeOneLandscape"};
            [self.book setObject:page forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        }

        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            self.pageTypeControl.selectedSegmentIndex = 0;
            ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            if (p) {
                UIImage *img = [UIImage imageWithCGImage:p.defaultRepresentation.fullScreenImage];
                CGSize size = img.size;
                if (size.width >= size.height) {
                    [cell useMainViewNamed:@"EditPageTypeOneLandscape" withGestureRecognizers:self.tapRecogs];
                }
                else {
                    [cell useMainViewNamed:@"EditPageTypeOnePortrait" withGestureRecognizers:self.tapRecogs];
                }

                [cell.mainView fillNth:1 withPhoto:p];
            }
            else {
                [cell useMainViewNamed:@"EditPageTypeOneLandscape" withGestureRecognizers:self.tapRecogs];
                [cell.mainView fillNth:1 withPhoto:nil];
            }
        }
        else {
            // two photos
            self.pageTypeControl.selectedSegmentIndex = 1;
            ALAsset *p1 = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            ALAsset *p2 = [self.poolViewController photoWithQuery:page[@"payload"][@"photo2"]];
            bool p1_landscape = NO, p2_landscape = NO;

            // check orientation
            if (p1) {
                UIImage *image = [UIImage imageWithCGImage:p1.defaultRepresentation.fullScreenImage];
                CGSize size = image.size;
                if (size.width >= size.height) {
                    p1_landscape = YES;
                }
            }
            if (p2) {
                UIImage *image = [UIImage imageWithCGImage:p2.defaultRepresentation.fullScreenImage];
                CGSize size = image.size;
                if (size.width >= size.height) {
                    p2_landscape = YES;
                }
            }

            // setup mainView
            if (p1_landscape) {
                if (p2_landscape) {
                    // two landscape
                    [cell useMainViewNamed:@"EditPageTypeTwoLandscape" withGestureRecognizers:self.tapRecogs];
                } else {
                    // mixed left landscape
                    [cell useMainViewNamed:@"EditPageTypeMixedLeftLandscape" withGestureRecognizers:self.tapRecogs];
                }
            } else {
                if (p2_landscape) {
                    // mixed left portrait
                    [cell useMainViewNamed:@"EditPageTypeMixedLeftPortrait" withGestureRecognizers:self.tapRecogs];
                } else {
                    // two portrait
                    [cell useMainViewNamed:@"EditPageTypeTwoPortrait" withGestureRecognizers:self.tapRecogs];
                }
            }

            // fill mainView
            [cell.mainView fillNth:1 withPhoto:p1];
            [cell.mainView fillNth:2 withPhoto:p2];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
        NSInteger pageIndex = [self pageIndex];
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
            if (p) {
                [self.poolViewController dropPhoto:p];
            }
            [self.book setObject:@{@"payload": @{@"photo": @""}, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        } else {
            if ([sender.view isEqual:cell.mainView.imageView1]) {
                // drop p1
                ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo"]];
                if (p) {
                    [self.poolViewController dropPhoto:p];
                }
                NSMutableDictionary *newpayload = [NSMutableDictionary dictionaryWithDictionary:page[@"payload"]];
                newpayload[@"photo"] = @"";
                [self.book setObject:@{@"payload": newpayload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
            } else {
                // drop p2
                ALAsset *p = [self.poolViewController photoWithQuery:page[@"payload"][@"photo2"]];
                if (p) {
                    [self.poolViewController dropPhoto:p];
                }
                NSMutableDictionary *newpayload = [NSMutableDictionary dictionaryWithDictionary:page[@"payload"]];
                newpayload[@"photo2"] = @"";
                [self.book setObject:@{@"payload": newpayload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
            }
        }
        [self.pagesCollectionView reloadData];
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

- (void)didSelectPhoto:(ALAsset *)p
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSInteger pageIndex = [self.pagesCollectionView indexPathForCell:cell].row;
    if (pageIndex == kJGIndexCoverPage) {
        if (self.pageTypeControl.selectedSegmentIndex == 1) {
            [cell.mainView fillNth:1 withPhoto:p];

            [self.book setObject:[p.defaultRepresentation.url query] forKey:@"cover_photo"];
        }
    }
    else if (pageIndex >= kJGIndexPhotoPageStart && pageIndex < kJGIndexBackcoverPage) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];

        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            if (page[@"payload"][@"photo"] && ![page[@"payload"][@"photo"] isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这一页放不下更多照片了" message:@"试试点击书中的照片来撤销" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self.poolViewController usePhoto:p];
                NSDictionary *newpayload = @{@"photo": [p.defaultRepresentation.url query]};
                [self.book setObject:@{@"payload": newpayload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]
                 ];
            }
        } else {
            bool p1 = page[@"payload"][@"photo"] && ![page[@"payload"][@"photo"] isEqualToString:@""];
            bool p2 = page[@"payload"][@"photo2"] && ![page[@"payload"][@"photo2"] isEqualToString:@""];
            if (p1 && p2) {
                // full
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这一页放不下更多照片了" message:@"试试点击书中的照片来撤销" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else if (p1) {
                // has p1, set p2
                [self.poolViewController usePhoto:p];
                NSMutableDictionary *newpayload = [NSMutableDictionary dictionaryWithDictionary:page[@"payload"]];
                newpayload[@"photo2"] = [p.defaultRepresentation.url query];
                [self.book setObject:@{@"payload": newpayload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]
                 ];
            } else {
                // no photo or has p2, set p1
                [self.poolViewController usePhoto:p];
                NSMutableDictionary *newpayload = [NSMutableDictionary dictionaryWithDictionary:page[@"payload"]];
                newpayload[@"photo"] = [p.defaultRepresentation.url query];
                [self.book setObject:@{@"payload": newpayload, @"type": page[@"type"]} forKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]
                 ];
            }
        }
        [self.pagesCollectionView reloadData];
    }
}

@end
