//
//  JGCoverViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 3/1/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGCoverViewController.h"
#import "JGEditPageMainView.h"
#import "JGImagePoolViewController.h"

@interface JGCoverViewController () <UIAlertViewDelegate, JGImagePoolShuffleDelegate>

@property (weak, nonatomic) IBOutlet UIView *wrapperView;

@property (nonatomic) JGEditPageMainView *mainView;
@property (weak, nonatomic) JGImagePoolViewController *poolViewController;
@property (weak, nonatomic) NSMutableDictionary *book;

@end

@implementation JGCoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.poolViewController = (JGImagePoolViewController *)((UINavigationController *)self.navigationController).parentViewController;
    self.poolViewController.shuffleDelegate = self;
    self.book = self.poolViewController.book;

    self.mainView = [[[NSBundle mainBundle] loadNibNamed:@"EditPageCover" owner:self options:nil] firstObject];
    [self.wrapperView addSubview:self.mainView];

    [self.poolViewController shufflePressed:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.poolViewController switchToShuffleButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    for (int i=0; i<9; i++) {
        [self.book removeObjectForKey:[NSString stringWithFormat:@"cover%d", i+1]];
    }
    [self.poolViewController switchToPool];
}

- (void)shuffledPhotos:(NSArray *)photos
{
    for (int i=0; i<9; i++) {
        ALAsset *p = photos[i];
        [self.mainView fillCoverNth:i+1 withPhoto:p];
        self.book[[NSString stringWithFormat:@"cover%d", i+1]] = [p.defaultRepresentation.url absoluteString];
    }
}

#pragma mark - Segue

- (IBAction)submitClicked:(id)sender {
    // user confirm
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认提交" message:@"提交之后不能再次修改，确认提交画册吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交", nil];
    [alertView show];
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.poolViewController saveBookAndExit];
    }
}

@end
