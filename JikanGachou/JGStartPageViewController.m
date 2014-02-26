//
//  JGStartPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 12/4/13.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGStartPageViewController.h"
#import "JGAppDelegate.h"
#import "JGBookTableViewController.h"
#import "JGImagePoolViewController.h"
#import <KIImagePager.h>
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.imagePager.pageControlCenter = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 16);
}

- (NSArray *)arrayWithImages
{
    return @[[UIImage imageNamed:@"start1.jpg"],
             [UIImage imageNamed:@"start2.jpg"],
             [UIImage imageNamed:@"start3.jpg"]];
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
        [self performSegueWithIdentifier:@"listBooks" sender:self];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"画册错误" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"listBooks"]) {
         JGBookTableViewController *vc = (JGBookTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        vc.openBookUUID = self.book[@"key"];
    }
    if ([segue.identifier isEqualToString:@"newBook"]) {
        JGImagePoolViewController *vc = (JGImagePoolViewController *)segue.destinationViewController;
        vc.homeVC = self;
    }
}

@end
