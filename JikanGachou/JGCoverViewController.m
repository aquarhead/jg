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

@interface JGCoverViewController () <UIAlertViewDelegate>

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
    self.book = self.poolViewController.book;

    self.mainView = [[[NSBundle mainBundle] loadNibNamed:@"EditPageCover" owner:self options:nil] firstObject];
    [self.wrapperView addSubview:self.mainView];
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
