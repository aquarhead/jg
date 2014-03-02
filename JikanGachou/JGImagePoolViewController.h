//
//  JGImagePoolViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JGStartPageViewController.h"

@protocol JGImagePoolDelegate <NSObject>

@required

- (void)didSelectPhoto:(ALAsset *)photo;
- (void)lockInteraction;
- (void)unlockInteraction;
- (void)didTapPlaceholder;

@end

@protocol JGImagePoolShuffleDelegate <NSObject>

@required

- (void)shuffledPhotos:(NSArray *)photos;

@end

@interface JGImagePoolViewController : UIViewController

@property (nonatomic) ALAssetsLibrary *lib;
@property (nonatomic, weak) id<JGImagePoolDelegate> delegate;
@property (nonatomic, weak) id<JGImagePoolShuffleDelegate> shuffleDelegate;
@property (nonatomic, weak) JGStartPageViewController *homeVC;

@property (nonatomic) NSMutableDictionary *book;

- (void)switchToPool;
- (void)switchToShuffleButton;
- (IBAction)shufflePressed:(UIButton *)sender;

- (void)addPhoto:(ALAsset *)photo;
- (void)removePhoto:(ALAsset *)photo;
- (BOOL)hasPhoto:(ALAsset *)photo;

- (void)usePhoto:(ALAsset *)photo;
- (void)dropPhoto:(ALAsset *)photo;
- (BOOL)isUsedPhoto:(ALAsset *)photo;

- (ALAsset *)photoWithURLString:(NSString *)urlstr;

- (BOOL)isValidNumberOfPhotos;
- (BOOL)poolFull;

- (void)saveBookAndExit;

@end
