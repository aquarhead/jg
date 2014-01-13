//
//  JGImagePoolViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <NanoStore.h>

@protocol JGImagePoolDelegate <NSObject>

@required

- (void)didSelectPhoto:(ALAsset *)photoInfo;

@end

@interface JGImagePoolViewController : UIViewController

@property (nonatomic) ALAssetsLibrary *lib;
@property (nonatomic) NSMutableArray *selectedPhotos;
@property (nonatomic, weak) id <JGImagePoolDelegate> delegate;

@property (nonatomic) NSFNanoObject *book;

- (void)addPhoto:(ALAsset *)photoInfo;
- (void)removePhoto:(ALAsset *)photoInfo;
- (BOOL)hasPhoto:(ALAsset *)photoInfo;
- (ALAsset *)photoWithQuery:(NSString *)query;
- (BOOL)isValidNumberOfPhotos;
- (BOOL)poolFull;

@end
