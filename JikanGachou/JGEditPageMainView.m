//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"

@interface JGEditPageMainView () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *yearLabel1;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel1;

@property (weak, nonatomic) IBOutlet UILabel *yearLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel2;

// for cover only
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;
@property (weak, nonatomic) IBOutlet UIImageView *imageView7;
@property (weak, nonatomic) IBOutlet UIImageView *imageView8;
@property (weak, nonatomic) IBOutlet UIImageView *imageView9;

@end

@implementation JGEditPageMainView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.titleTextField.delegate = self;
    self.authorTextField.delegate = self;
    self.descriptionTextView1.delegate = self;
    self.descriptionTextView2.delegate = self;

    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
}

- (void)fillNth:(NSUInteger)n withPhoto:(ALAsset *)p
{
    UIImageView *imageView = [self valueForKey:[NSString stringWithFormat:@"imageView%lu", (unsigned long)n]];
    UILabel *yearLabel = [self valueForKey:[NSString stringWithFormat:@"yearLabel%lu", (unsigned long)n]];
    UILabel *dayLabel = [self valueForKey:[NSString stringWithFormat:@"dayLabel%lu", (unsigned long)n]];

    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;

        NSDate *date = [p valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *yearFormatter, *dayFormatter;
        if (!yearFormatter) {
            yearFormatter = [NSDateFormatter new];
            yearFormatter.dateFormat = @" MMMM YYYY";
            dayFormatter = [NSDateFormatter new];
            dayFormatter.dateFormat = @" d ";
        }
        yearLabel.text = [yearFormatter stringFromDate:date];
        dayLabel.text = [dayFormatter stringFromDate:date];

        yearLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1];
        dayLabel.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1];
    }
    else {
        imageView.image = [UIImage imageNamed:@"Placeholder"];
        imageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)fillCoverNth:(NSUInteger)n withPhoto:(ALAsset *)p
{
    UIImageView *imageView = [self valueForKey:[NSString stringWithFormat:@"imageView%lu", (unsigned long)n]];

    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.aspectRatioThumbnail];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        imageView.image = [UIImage imageNamed:@"Placeholder"];
        imageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)fillNth:(NSUInteger)n withText:(NSString *)text
{
    UITextView *textView = [self valueForKey:[NSString stringWithFormat:@"descriptionTextView%lu", (unsigned long)n]];
    textView.text = text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"点击添加描述…"]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"点击添加描述…";
        textView.textColor = [UIColor lightGrayColor];
    }
    if ([textView isEqual:self.descriptionTextView1]) {
        [self.delegate saveDescriptionText:textView.text];
    } else {
        [self.delegate saveDescriptionText2:textView.text];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (textView.text.length >= 20 && text.length > 0 && range.length == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"描述太长了" message:@"描述最多为 20 个字" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField) {
        [self.authorTextField becomeFirstResponder];
    } else {
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
