//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"

@interface JGEditPageMainView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel1;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel2;

@end

@implementation JGEditPageMainView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleTextField.delegate = self;
    self.authorTextField.delegate = self;

    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
}

- (void)fillNth:(NSUInteger)n withPhoto:(ALAsset *)p
{
    UIImageView *imageView = [self valueForKey:[NSString stringWithFormat:@"imageView%lu", (unsigned long)n]];
    UILabel *dateLabel = [self valueForKey:[NSString stringWithFormat:@"dateLabel%lu", (unsigned long)n]];
    
    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.defaultRepresentation.fullScreenImage];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSDate *date = [p valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *formatter;
        if (!formatter) {
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
        }
        dateLabel.text = [formatter stringFromDate:date];
    }
    else {
        imageView.image = [UIImage imageNamed:@"Placeholder"];
        imageView.contentMode = UIViewContentModeScaleToFill;
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
