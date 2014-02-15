//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import <KIImagePager.h>
#import "JGAppDelegate.h"
#import "JGSubmitPageViewController.h"
#import <NyaruDB.h>

@interface JGStartPageViewController () <KIImagePagerDataSource>

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (nonatomic) NSDictionary *book;

@end

@implementation JGStartPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JGAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.rootVC = self;
    
    self.imagePager.dataSource = self;
    self.imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    self.imagePager.backgroundColor = [UIColor whiteColor];
    self.imagePager.slideshowTimeInterval = 7.0;
    self.imagePager.imageCounterDisabled = YES;
}

- (NSArray *)arrayWithImages
{
    return @[[UIImage imageNamed:@"start1"],
             [UIImage imageNamed:@"start2"]];
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

- (void)openWithBookUUID:(NSString *)uuid
{
    NyaruDB *db = [NyaruDB instance];
    NyaruCollection *co = [db collection:@"books"];
    NSArray *documents = [[co where:@"key" equal:uuid] fetch];
    if (documents.count > 0) {
        self.book = documents[0];
        [self performSegueWithIdentifier:@"openSubmit" sender:self];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相册错误" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openSubmit"]) {
        JGSubmitPageViewController *vc = (JGSubmitPageViewController *)((UINavigationController *)segue.destinationViewController).topViewController;;
        vc.book = [self.book copy];
    }
}

@end
