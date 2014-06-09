//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"
#include <sys/sysctl.h>
@import AssetsLibrary;

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

    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
}

- (NSString *)modelString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *model = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return model;
}

- (void)fillNth:(NSUInteger)n withPhotoObject:(JGPhotoObject *)pobj
{
    UIImageView *imageView = [self valueForKey:[NSString stringWithFormat:@"imageView%lu", (unsigned long)n]];
//    UITextView *textView = [self valueForKey:[NSString stringWithFormat:@"descriptionTextView%lu", (unsigned long)n]];
    UILabel *yearLabel = [self valueForKey:[NSString stringWithFormat:@"yearLabel%lu", (unsigned long)n]];
    UILabel *dayLabel = [self valueForKey:[NSString stringWithFormat:@"dayLabel%lu", (unsigned long)n]];

    UIImage *image;
    if ([[self modelString] hasPrefix:@"iPhone3"]) {
        // iPhone3 is iPhone 4, the only A4 device runs iOS 7
        image = [UIImage imageWithCGImage:pobj.asset.aspectRatioThumbnail];
    }
    else {
        image = [UIImage imageWithCGImage:pobj.asset.defaultRepresentation.fullScreenImage];
    }
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;

    static NSDateFormatter *yearFormatter, *dayFormatter;
    if (!yearFormatter) {
        yearFormatter = [NSDateFormatter new];
        [yearFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        yearFormatter.dateFormat = @" MMMM YYYY";
        dayFormatter = [NSDateFormatter new];
        dayFormatter.dateFormat = @" d ";
    }
    yearLabel.text = [yearFormatter stringFromDate:pobj.date];
    dayLabel.text = [dayFormatter stringFromDate:pobj.date];

    yearLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1];
    dayLabel.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1];
}

@end
