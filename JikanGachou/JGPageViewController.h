//
//  JGPageViewController.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 5/17/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGShowPagesViewController.h"

@interface JGPageViewController : UIViewController <JGShowPagesContent>

@property (nonatomic, strong) NSString *pageIndex;

@end
