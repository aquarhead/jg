//
//  JGCoverViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 3/1/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGCoverViewController.h"
#import "JGEditPageMainView.h"

@interface JGCoverViewController ()

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (nonatomic) JGEditPageMainView *mainView;

@end

@implementation JGCoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mainView = [[[NSBundle mainBundle] loadNibNamed:@"EditPageCover" owner:self options:nil] firstObject];
    [self.wrapperView addSubview:self.mainView];
}

@end
