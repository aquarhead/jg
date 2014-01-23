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

@end
