//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"

@interface JGEditPageMainView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondDateLabel;

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

- (void)putFirstPhoto:(ALAsset *)p
{
    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.defaultRepresentation.fullScreenImage];
        self.firstImageView.image = image;
        self.firstImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSDate *date = [p valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *formatter;
        if (!formatter) {
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
        }
        self.firstDateLabel.text = [formatter stringFromDate:date];
    }
    else {
        self.firstImageView.image = [UIImage imageNamed:@"Placeholder"];
        self.firstImageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)putSecondPhoto:(ALAsset *)p
{
    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.defaultRepresentation.fullScreenImage];
        self.secondImageView.image = image;
        self.secondImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSDate *date = [p valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *formatter;
        if (!formatter) {
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
        }
        self.secondDateLabel.text = [formatter stringFromDate:date];
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
