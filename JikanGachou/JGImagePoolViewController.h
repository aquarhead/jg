//
//  JGImagePoolViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface JGImagePoolViewController : UIViewController

@property (nonatomic) ALAssetsLibrary *lib;

- (void)addPhoto:(ALAsset *)photoInfo;
- (void)removePhoto:(ALAsset *)photoInfo;
- (BOOL)hasPhoto:(ALAsset *)photoInfo;

@end
