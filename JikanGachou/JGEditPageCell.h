//
//  JGEditPageCell.h
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGEditPageMainView.h"

@interface JGEditPageCell : UICollectionViewCell

@property (nonatomic) JGEditPageMainView *mainView;

- (void)addViewNamed:(NSString *)name;

@end