//
//  JGEditPageCell.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageCell.h"

@implementation JGEditPageCell

- (void)useMainViewNamed:(NSString *)name withGestureRecognizers:(NSArray *)recogs
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.mainView = [[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] firstObject];
    [self addSubview:self.mainView];
    if ([name hasPrefix:@"EditPageTypeOne"]) {
        [self.mainView.firstImageView addGestureRecognizer:recogs[0]];
    } else if ([name hasPrefix:@"EditPageTypeTwo"] || [name hasPrefix:@"EditPageTypeMixed"]) {
        [self.mainView.firstImageView addGestureRecognizer:recogs[0]];
        [self.mainView.secondImageView addGestureRecognizer:recogs[1]];
    }
}

@end
