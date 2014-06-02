//
//  JGPhotoObject.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/31/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AssetsLibrary;

@interface JGPhotoObject : NSObject

@property (strong) NSString *url;
@property (strong) NSString *text;
@property (strong) NSDate *date;
@property (strong) ALAsset *asset;

@property UIImageView *imageView;

@end
