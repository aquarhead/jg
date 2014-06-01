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

@interface JGImagePoolViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *barView;

@property (nonatomic) ALAssetsLibrary *lib;
@property (nonatomic, weak) id<JGImagePoolDelegate> delegate;
@property (nonatomic, weak) JGStartPageViewController *homeVC;
@property (nonatomic) NSMutableDictionary *book;
@property (nonatomic, assign) BOOL coached;

- (NSArray *)shuffledPhotos;

- (void)addPhoto:(ALAsset *)photo;
- (void)removePhoto:(ALAsset *)photo;
- (BOOL)hasPhoto:(ALAsset *)photo;

- (void)usePhoto:(ALAsset *)photo;
- (void)dropPhoto:(ALAsset *)photo;
- (BOOL)isUsedPhoto:(ALAsset *)photo;

- (ALAsset *)photoWithURLString:(NSString *)urlstr;

- (BOOL)isValidNumberOfPhotos;
- (BOOL)poolFull;

- (void)startCreateBook;
- (void)saveBookAndExit;

@end
