//
//  JGImageGridViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface JGImageGridViewController : UIViewController

@property (nonatomic) ALAssetsGroup *group;
@property (nonatomic) NSArray *photos;

@end
