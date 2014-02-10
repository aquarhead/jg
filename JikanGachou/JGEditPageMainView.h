//
//  JGEditPageContentView.h
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol JGEditPageDelegate <NSObject>

@required

- (void)saveTitle:(NSString *)title;
- (void)saveAuthor:(NSString *)author;

@end

@interface JGEditPageMainView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;

@property (nonatomic, weak) id<JGEditPageDelegate> delegate;

- (void)putFirstPhoto:(ALAsset *)p;
- (void)putSecondPhoto:(ALAsset *)p;

@end
