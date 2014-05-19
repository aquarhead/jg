//
//  JGTransparentViewController.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/19/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGShowPagesViewController.h"

@interface JGTransparentViewController : UIViewController <JGShowPagesContent>

@property (nonatomic, strong) NSString *pageIndex;

@end
