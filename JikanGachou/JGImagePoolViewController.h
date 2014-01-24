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

- (void)didSelectPhoto:(ALAsset *)photo;

@end

@interface JGImagePoolViewController : UIViewController

@property (nonatomic) ALAssetsLibrary *lib;
@property (nonatomic, weak) id <JGImagePoolDelegate> delegate;

@property (nonatomic) NSFNanoObject *book;

- (void)addPhoto:(ALAsset *)photo;
- (void)removePhoto:(ALAsset *)photo;
- (BOOL)hasPhoto:(ALAsset *)photo;
- (void)usePhoto:(ALAsset *)photo;
- (void)dropPhoto:(ALAsset *)photo;

- (ALAsset *)photoWithQuery:(NSString *)query;

- (BOOL)isValidNumberOfPhotos;
- (BOOL)poolFull;

@end
