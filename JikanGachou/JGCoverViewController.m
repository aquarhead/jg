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

    for (int i = 0; i < 9; ++i) {
        [self.book removeObjectForKey:[NSString stringWithFormat:@"cover%d", i+1]];
    }
    [self.poolViewController switchToPool];
}

- (void)shuffledPhotos:(NSArray *)photos
{
    for (int i = 0; i < MIN(9, photos.count); ++i) {
        ALAsset *p = photos[i];
        [self.mainView fillCoverNth:i+1 withPhoto:p];
        self.book[[NSString stringWithFormat:@"cover%d", i+1]] = [p.defaultRepresentation.url absoluteString];
    }
}



@end
