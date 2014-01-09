//
//  JGEditPageCell.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageCell.h"

@implementation JGEditPageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addViewNamed:(NSString *)name
{
    self.mainView = [[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] firstObject];
    [self addSubview:self.mainView];
}

@end
