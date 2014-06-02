//
//  JGEditPageContentView.h
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGPhotoObject.h"
@import AssetsLibrary;

@protocol JGEditPageDelegate <NSObject>

@required

- (void)saveTitle:(NSString *)title;
- (void)saveAuthor:(NSString *)author;
- (void)saveDescriptionText:(NSString *)descriptionText;
- (void)saveDescriptionText2:(NSString *)descriptionText;

@end

@interface JGEditPageMainView : UIView

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView1;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView2;

@property (nonatomic, weak) id<JGEditPageDelegate> delegate;

- (void)fillNth:(NSUInteger)n withPhoto:(ALAsset *)p;
- (void)fillCoverNth:(NSUInteger)n withPhoto:(ALAsset *)p;
- (void)fillNth:(NSUInteger)n withText:(NSString *)text;

- (void)fillNth:(NSUInteger)n withPhotoAsset:(ALAsset *)pa text:(NSString *)text andDate:(NSDate *)date;

@end
