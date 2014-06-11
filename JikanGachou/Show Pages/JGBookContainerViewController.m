//
//  JGBookContainerViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 5/18/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGBookContainerViewController.h"
#import "JGShowPagesViewController.h"

@interface JGBookContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation JGBookContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.container.layer.masksToBounds = NO;
    self.container.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.container.layer.shadowRadius = 1.5;
    self.container.layer.shadowOpacity = 0.3;
}

- (IBAction)backPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Set Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedShowPages"]) {
        JGShowPagesViewController *vc = segue.destinationViewController;
        vc.photos = [self.photos copy];
        vc.poolViewController = self.poolViewController;
    }
}

@end
