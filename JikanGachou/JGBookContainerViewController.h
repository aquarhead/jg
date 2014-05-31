//
//  JGBookContainerViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 5/18/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGImagePoolViewController.h"

@interface JGBookContainerViewController : UIViewController

@property (strong) NSArray *photos;
@property (weak, nonatomic) JGImagePoolViewController *poolViewController;

@end
