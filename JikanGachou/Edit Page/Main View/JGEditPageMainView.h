//
//  JGEditPageContentView.h
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGPhotoObject.h"

@interface JGEditPageMainView : UIView

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

- (void)fillNth:(NSUInteger)n withPhotoObject:(JGPhotoObject *)pobj;
- (void)fillCoverNth:(NSUInteger)n withPhotoObject:(JGPhotoObject *)pobj;

@end
