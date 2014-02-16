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

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (nonatomic, weak) id<JGEditPageDelegate> delegate;

- (void)fillNth:(NSUInteger)n withPhoto:(ALAsset *)p;

@end
