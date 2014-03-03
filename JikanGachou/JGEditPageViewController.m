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
#import <MRProgress.h>

static const NSInteger kJGIndexCoverPage = 0;
static const NSInteger kJGIndexFlyleafPage = kJGIndexCoverPage + 1;
static const NSInteger kJGIndexPhotoPageStart = kJGIndexFlyleafPage + 1;
static const NSInteger kJGIndexPhotoPageEnd = kJGIndexPhotoPageStart + 20 - 1;
static const NSInteger kJGIndexBackcoverPage = kJGIndexPhotoPageEnd + 1;
static const NSInteger kJGTotalPages = kJGIndexBackcoverPage + 1;

@interface JGEditPageViewController () <UIAlertViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, JGImagePoolDelegate, JGEditPageDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *pagesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewYConstraint;

@property (nonatomic) NSArray *tapRecogs;

@property (weak, nonatomic) JGImagePoolViewController *poolViewController;
@property (weak, nonatomic) NSMutableDictionary *book;
@property (nonatomic) UISegmentedControl *pageTypeControl;
@property (nonatomic) BOOL movedUp;

@end

@implementation JGEditPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.poolViewController = (JGImagePoolViewController *)((UINavigationController *)self.navigationController).parentViewController;
    self.poolViewController.delegate = self;
    self.book = self.poolViewController.book;
    self.movedUp = NO;

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
    self.pageTypeControl = [[UISegmentedControl alloc] initWithItems:@[@"单图", @"双图"]];
    self.navigationItem.titleView = self.pageTypeControl;
    [self reloadSegmentedControl];

    self.pageTypeControl.frame = CGRectMake(0, 0, 130, 30);
    [self.pageTypeControl addTarget:self action:@selector(pageTypeChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Segue

- (IBAction)submitClicked:(id)sender {
    [self hideKeyboard];
    NSString *errmsg = nil;
    NSIndexPath *idxp = nil;
#ifndef DEBUG
    // check 20 pages
    for (int pageIndex=0; pageIndex<20; pageIndex++) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%d", pageIndex]];
        if (!page
            || !page[@"photo"]
            || (![page[@"type"] hasPrefix:@"EditPageTypeOne"] && !page[@"photo2"])) {
            errmsg = @"请选择想打印的照片";
            idxp = [NSIndexPath indexPathForItem:pageIndex+kJGIndexPhotoPageStart inSection:0];
            break;
        }
    }
#endif
    // check title and author
    if (![self.book objectForKey:@"author"]
        || [[self.book objectForKey:@"author"] isEqualToString:@""]) {
        errmsg = @"请填写作者";
        idxp = [NSIndexPath indexPathForItem:kJGIndexFlyleafPage inSection:0];
    }
    if (![self.book objectForKey:@"title"]
        || [[self.book objectForKey:@"title"] isEqualToString:@""]) {
        errmsg = @"请填写画册名";
        idxp = [NSIndexPath indexPathForItem:kJGIndexFlyleafPage inSection:0];
    }
    if (errmsg) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"画册不完整" message:errmsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.pagesCollectionView scrollToItemAtIndexPath:idxp atScrollPosition:0 animated:YES];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认提交" message:@"提交之后不能再次修改，确认提交画册吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交", nil];
        [alertView show];
    }
}

#pragma mark - Keyboard related

- (BOOL)needsMoveUp
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    UIView *firstResponder;
    if ([cell.mainView.titleTextField isFirstResponder]) {
        firstResponder = cell.mainView.titleTextField;
    }
    else if ([cell.mainView.authorTextField isFirstResponder]) {
        firstResponder = cell.mainView.authorTextField;
    }
    else if ([cell.mainView.descriptionTextView1 isFirstResponder]) {
        firstResponder = cell.mainView.descriptionTextView1;
    }
    else if ([cell.mainView.descriptionTextView2 isFirstResponder]) {
        firstResponder = cell.mainView.descriptionTextView2;
    }

    if (firstResponder.center.y < 150) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;

    CGFloat keyboardHeightBegin = CGRectGetHeight([userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]);
    CGFloat keyboardHeightEnd = CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    if (keyboardHeightBegin != keyboardHeightEnd) {
        // candidate bar appear / disappear
        return;
    }

    if ([self needsMoveUp] && !self.movedUp) {
        self.movedUp = YES;
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.collectionViewYConstraint.constant += (IS_R4 ? 80 : 120);
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.movedUp) {
        self.movedUp = NO;
        NSDictionary *userInfo = notification.userInfo;
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.collectionViewYConstraint.constant -= (IS_R4 ? 80 : 120);
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideKeyboard
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSUInteger pageIndex = [self pageIndex];
    
    if (pageIndex == kJGIndexFlyleafPage) {
        [cell.mainView.titleTextField resignFirstResponder];
        [cell.mainView.authorTextField resignFirstResponder];
    }
    else if (pageIndex >= kJGIndexPhotoPageStart && pageIndex <= kJGIndexPhotoPageEnd) {
        [cell.mainView.descriptionTextView1 resignFirstResponder];
        [cell.mainView.descriptionTextView2 resignFirstResponder];
    }
}

- (IBAction)collectionViewTouched:(UITapGestureRecognizer *)sender
{
    [self hideKeyboard];
}

- (void)saveTitle:(NSString *)title
{
    self.book[@"title"] = title;
}

- (void)saveAuthor:(NSString *)author
{
    self.book[@"author"] = author;
}

- (void)saveDescriptionText:(NSString *)descriptionText
{
    NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)[self pageIndex]-kJGIndexPhotoPageStart];
    NSMutableDictionary *newpage = [self.book[pageKey] mutableCopy];
    newpage[@"text"] = descriptionText;
    self.book[pageKey] = [newpage copy];
}

- (void)saveDescriptionText2:(NSString *)descriptionText
{
    NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)[self pageIndex]-kJGIndexPhotoPageStart];
    NSMutableDictionary *newpage = [self.book[pageKey] mutableCopy];
    newpage[@"text2"] = descriptionText;
    self.book[pageKey] = [newpage copy];
}

#pragma mark - Scroll View

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadSegmentedControl];
}

- (void)reloadSegmentedControl
{
    NSUInteger pageIndex = [self pageIndex];
    if (pageIndex >= kJGIndexPhotoPageStart && pageIndex <= kJGIndexPhotoPageEnd) {
        self.pageTypeControl.hidden = NO;
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart]];
        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            self.pageTypeControl.selectedSegmentIndex = 0;
        } else {
            self.pageTypeControl.selectedSegmentIndex = 1;
        }
    } else {
        self.pageTypeControl.hidden = YES;
    }
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
    return kJGTotalPages;
}

- (void)pageTypeChanged:(UISegmentedControl *)sender
{
    NSUInteger pageIndex = [self pageIndex];
    NSString *type = (sender.selectedSegmentIndex == 0 ? @"EditPageTypeOneLandscape" : @"EditPageTypeTwoLandscape");
    NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart];
    NSMutableDictionary *page = [self.book[pageKey] mutableCopy];
    if (page) {
        if ([page[@"type"] hasPrefix:@"EditPageTypeTwo"] || [page[@"type"] hasPrefix:@"EditPageTypeMixed"]) {
            // drop photo2
            ALAsset *p = [self.poolViewController photoWithURLString:page[@"photo2"]];
            if (p) {
                [self.poolViewController dropPhoto:p];
            }
            page[@"photo2"] = @"";
        }
        page[@"type"] = type;
        self.book[pageKey] = [page copy];
    }
    else {
        self.book[pageKey] = @{@"type": type};
    }

    [self.pagesCollectionView reloadData];
}

- (void)setupCell:(JGEditPageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger pageIndex = indexPath.item;

    if (pageIndex == kJGIndexCoverPage) {
        [cell useMainViewNamed:@"EditPageCover" withGestureRecognizers:self.tapRecogs];
    }
    else if (pageIndex == kJGIndexFlyleafPage) {
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
        [cell useMainViewNamed:@"EditPageBackCover" withGestureRecognizers:self.tapRecogs];
    }
    else {
        NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart];
        NSMutableDictionary *page = [self.book[pageKey] mutableCopy];
        if (!page) {
            page = [NSMutableDictionary new];
            page[@"type"] = @"EditPageTypeOneLandscape";
        }

        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            ALAsset *p = [self.poolViewController photoWithURLString:page[@"photo"]];
            if (p) {
                UIImage *img = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
                CGSize size = img.size;
                if (size.width >= size.height) {
                    [cell useMainViewNamed:@"EditPageTypeOneLandscape" withGestureRecognizers:self.tapRecogs];
                    page[@"type"] = @"EditPageTypeOneLandscape";
                } else {
                    [cell useMainViewNamed:@"EditPageTypeOnePortrait" withGestureRecognizers:self.tapRecogs];
                    page[@"type"] = @"EditPageTypeOnePortrait";
                }

                [cell.mainView fillNth:1 withPhoto:p];
            } else {
                [cell useMainViewNamed:@"EditPageTypeOneLandscape" withGestureRecognizers:self.tapRecogs];
                [cell.mainView fillNth:1 withPhoto:nil];
            }
        } else {
            // two photos
            ALAsset *p1 = [self.poolViewController photoWithURLString:page[@"photo"]];
            ALAsset *p2 = [self.poolViewController photoWithURLString:page[@"photo2"]];
            bool p1_landscape = NO, p2_landscape = NO;

            // check orientation
            if (p1) {
                UIImage *image = [UIImage imageWithCGImage:p1.aspectRatioThumbnail];
                CGSize size = image.size;
                if (size.width >= size.height) {
                    p1_landscape = YES;
                }
            }
            if (p2) {
                UIImage *image = [UIImage imageWithCGImage:p2.aspectRatioThumbnail];
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
                    page[@"type"] = @"EditPageTypeTwoLandscape";
                } else {
                    // mixed left landscape
                    [cell useMainViewNamed:@"EditPageTypeMixedLeftLandscape" withGestureRecognizers:self.tapRecogs];
                    page[@"type"] = @"EditPageTypeMixedLeftLandscape";
                }
            } else {
                if (p2_landscape) {
                    // mixed left portrait
                    [cell useMainViewNamed:@"EditPageTypeMixedLeftPortrait" withGestureRecognizers:self.tapRecogs];
                    page[@"type"] = @"EditPageTypeMixedLeftPortrait";
                } else {
                    // two portrait
                    [cell useMainViewNamed:@"EditPageTypeTwoPortrait" withGestureRecognizers:self.tapRecogs];
                    page[@"type"] = @"EditPageTypeTwoPortrait";
                }
            }

            // fill mainView
            [cell.mainView fillNth:1 withPhoto:p1];
            [cell.mainView fillNth:2 withPhoto:p2];

            if (page[@"text2"] && ![page[@"text2"] isEqualToString:@""]) {
                [cell.mainView fillNth:2 withText:page[@"text2"]];
            }
        }
        cell.mainView.delegate = self;
        if (page[@"text"] && ![page[@"text"] isEqualToString:@""]) {
            [cell.mainView fillNth:1 withText:page[@"text"]];
        }

        self.book[pageKey] = [page copy];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
        NSInteger pageIndex = [self pageIndex];
        NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart];
        NSMutableDictionary *page = [self.book[pageKey] mutableCopy];
        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            ALAsset *p = [self.poolViewController photoWithURLString:page[@"photo"]];
            if (p) {
                [self.poolViewController dropPhoto:p];
            }
            page[@"photo"] = @"";
        }
        else {
            if ([sender.view isEqual:cell.mainView.imageView1]) {
                // drop p1
                ALAsset *p = [self.poolViewController photoWithURLString:page[@"photo"]];
                if (p) {
                    [self.poolViewController dropPhoto:p];
                }
                page[@"photo"] = @"";
            }
            else {
                // drop p2
                ALAsset *p = [self.poolViewController photoWithURLString:page[@"photo2"]];
                if (p) {
                    [self.poolViewController dropPhoto:p];
                }
                page[@"photo2"] = @"";
            }
        }
        self.book[pageKey] = [page copy];
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
    [[MRNavigationBarProgressView progressViewForNavigationController:self.navigationController] setProgress:([self pageIndex] + 1.0) / kJGTotalPages animated:YES];
    [self reloadSegmentedControl];
}

#pragma mark - poolView delegate

- (void)didSelectPhoto:(ALAsset *)p
{
    JGEditPageCell *cell = [self.pagesCollectionView.visibleCells firstObject];
    NSInteger pageIndex = [self.pagesCollectionView indexPathForCell:cell].row;
    if (pageIndex >= kJGIndexPhotoPageStart && pageIndex < kJGIndexBackcoverPage) {
        NSString *pageKey = [NSString stringWithFormat:@"page%ld", (long)pageIndex-kJGIndexPhotoPageStart];
        NSMutableDictionary *page = [self.book[pageKey] mutableCopy];

        if ([page[@"type"] hasPrefix:@"EditPageTypeOne"]) {
            if (page[@"photo"] && ![page[@"photo"] isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这一页放不下更多照片了" message:@"试试点击书中的照片来撤销" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self.poolViewController usePhoto:p];
                page[@"photo"] = [p.defaultRepresentation.url absoluteString];
            }
        } else {
            bool p1 = page[@"photo"] && ![page[@"photo"] isEqualToString:@""];
            bool p2 = page[@"photo2"] && ![page[@"photo2"] isEqualToString:@""];
            if (p1 && p2) {
                // full
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这一页放不下更多照片了" message:@"试试点击书中的照片来撤销" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else if (p1) {
                // has p1, set p2
                [self.poolViewController usePhoto:p];
                page[@"photo2"] = [p.defaultRepresentation.url absoluteString];
            } else {
                // no photo or has p2, set p1
                [self.poolViewController usePhoto:p];
                page[@"photo"] = [p.defaultRepresentation.url absoluteString];
            }
        }
        self.book[pageKey] = [page copy];
        [self.pagesCollectionView reloadData];
    }
}

- (void)lockInteraction
{
    self.view.userInteractionEnabled = NO;
}

- (void)unlockInteraction
{
    self.view.userInteractionEnabled = YES;
}

- (void)didTapPlaceholder
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.poolViewController saveBookAndExit];
    }
}

@end
