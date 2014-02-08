//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"

@interface JGEditPageMainView () <UITextFieldDelegate>

@end

@implementation JGEditPageMainView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleTextField.delegate = self;
    self.authorTextField.delegate = self;

    self.firstImageView.userInteractionEnabled = YES;
    self.secondImageView.userInteractionEnabled = YES;
}

- (void)putFirstImage:(UIImage *)image
{
    if (image) {
        self.firstImageView.image = image;
        self.firstImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        self.firstImageView.image = [UIImage imageNamed:@"Placeholder"];
        self.firstImageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)putSecondImage:(UIImage *)image
{
    if (image) {
        self.secondImageView.image = image;
        self.secondImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        self.secondImageView.image = [UIImage imageNamed:@"Placeholder"];
        self.secondImageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField) {
        [self.authorTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.titleTextField]) {
        [self.delegate saveTitle:textField.text];
    } else if ([textField isEqual:self.authorTextField]) {
        [self.delegate saveAuthor:textField.text];
    }
}

@end
