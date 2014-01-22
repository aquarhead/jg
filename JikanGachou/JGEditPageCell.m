//
//  JGEditPageCell.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageCell.h"

@implementation JGEditPageCell

- (void)addViewNamed:(NSString *)name
{
    self.mainView = [[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] firstObject];
    [self addSubview:self.mainView];
}

@end
