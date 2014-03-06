//
//  JGSubmitPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 1/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGSubmitPageViewController.h"
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import <MRProgress.h>
#import <NyaruDB.h>
#import <MBProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager+timeout.h"

@interface JGSubmitPageViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) NSArray *photo_urls;
@property (nonatomic) NSArray *photos;
@property (nonatomic) ALAssetsLibrary *lib;

@property (nonatomic) AFHTTPRequestOperationManager *jgServerManager;
@property (nonatomic) NSUInteger finished;
@property (nonatomic) MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusItem;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@property (nonatomic) NSUInteger price;

@property (weak, nonatomic) IBOutlet UITableViewCell *payCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *uploadCell;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *payCells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *uploadCells;
@end

@implementation JGSubmitPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.book[@"title"];

    // setup StaticDataTableViewController
    self.hideSectionsWithHiddenRows = YES;
    [self cells:self.payCells setHidden:YES];
    [self cells:self.uploadCells setHidden:YES];
    [self reloadDataAnimated:YES];

    // load photos
    self.lib = [ALAssetsLibrary new];
    NSMutableArray *photo_urls = [NSMutableArray new];
    for (int i=0; i<20; i++) {
        NSDictionary *page = [self.book objectForKey:[NSString stringWithFormat:@"page%d", i]];
        // all these checks are redundant
        if (page) {
            if (page[@"photo"]) {
                [photo_urls addObject:page[@"photo"]];
            }
            if (page[@"type"] && ![page[@"type"] hasPrefix:@"EditPageTypeOne"] && page[@"photo2"]) {
                [photo_urls addObject:page[@"photo2"]];
            }
        }
    }
    for (int i = 1; i < 10; ++i) {
        id item = self.book[[NSString stringWithFormat:@"cover%d", i]];
        if (![photo_urls containsObject:item] && item) {
            [photo_urls addObject:item];
        }
    }
    self.photo_urls = [photo_urls copy];
    NSMutableArray *photos = [NSMutableArray new];
    for (NSString *urlstr in self.photo_urls) {
        [self.lib assetForURL:[NSURL URLWithString:urlstr] resultBlock:^(ALAsset *asset) {
            [photos addObject:asset];
            self.photos = [photos copy];
            if (self.photos.count == self.photo_urls.count) {
                [self updateTotalSize];
            }
        } failureBlock:^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法获取图片" message:@"请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.jgServerManager = [AFHTTPRequestOperationManager manager];

    // check status
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍候";
    self.navigationController.view.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book[@"key"]];
    [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqualToString:@"error"]) {
            self.book[@"status"] = @"topay";
        } else {
            self.book[@"status"] = responseObject[@"status"];
        }
        NSDictionary *statusDescription = @{@"topay": @"待付款",
                                            @"toupload": @"待上传",
                                            @"toprint": @"印刷中",
                                            @"shipping": @"已发货",
                                            @"recved": @"已收货"};
        self.statusItem.title = statusDescription[self.book[@"status"]];
        static NSDateFormatter *updatedFormatter;
        if (!updatedFormatter) {
            updatedFormatter = [NSDateFormatter new];
            updatedFormatter.dateFormat = @"yyyy年MM月dd日";
        }
        self.book[@"statusUpdated"] = [updatedFormatter stringFromDate:[NSDate date]];
        [self saveBook];
        if ([self.book[@"status"] isEqualToString:@"topay"]) {
            self.price = [responseObject[@"price"] unsignedLongValue];
            [self cells:self.payCells setHidden:NO];
            [self reloadDataAnimated:YES];
            [self quantityChanged:self];
        } else if ([self.book[@"status"] isEqualToString:@"toupload"]) {
            [self cells:self.uploadCells setHidden:NO];
            [self reloadDataAnimated:YES];
        }
        [hud hide:YES];
        self.navigationController.view.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.navigationController.view.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveBook];
    [super viewWillDisappear:animated];
}

- (void)saveBook
{
    NyaruDB *db = [NyaruDB instance];
    NyaruCollection *collection = [db collection:@"books"];
    [collection put:[self.book copy]];
    [collection waitForWriting];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.payCell) {
        [self pay];
    } else if (cell == self.uploadCell) {
        [self submit];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameField) {
        [self.phoneField becomeFirstResponder];
    } else if (textField == self.phoneField) {
        [self.addressTextView becomeFirstResponder];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.addressPlaceholder.hidden = (textView.text.length > 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)updateTotalSize
{
    long long totalsize = 0;
    for (ALAsset *p in self.photos) {
        totalsize += p.defaultRepresentation.size;
    }
    self.sizeCell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:totalsize countStyle:NSByteCountFormatterCountStyleBinary];
}

- (IBAction)quantityChanged:(id)sender
{
    long quantity = self.stepper.value;
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld 本", quantity];
    self.priceLabel.text = [NSString stringWithFormat:@"%ld 元", quantity * self.price];
}

- (void)pay
{
    [self.nameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.addressTextView resignFirstResponder];
    
    if ([self.nameField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写姓名" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.nameField becomeFirstResponder];
    } else if ([self.phoneField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写可用的手机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.phoneField becomeFirstResponder];
    } else if ([self.addressTextView.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收件人信息不完整" message:@"请填写完整的地址" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.addressTextView becomeFirstResponder];
    } else {
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            self.payCell.userInteractionEnabled = NO;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.book options:0 error:nil];
            NSDictionary *parameters = @{@"info": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding],
                                         @"recp": self.nameField.text,
                                         @"phone": self.phoneField.text,
                                         @"address": self.addressTextView.text,
                                         @"quantity": [NSString stringWithFormat:@"%d", (int)self.stepper.value]};
            NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book[@"key"]];
            [self.jgServerManager POST:addr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.payCell.userInteractionEnabled = YES;
                if ([responseObject[@"status"] isEqualToString:@"done"]) {
                    NSURL *url = [NSURL URLWithString:[responseObject[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[UIApplication sharedApplication] openURL:url];
                    }];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:responseObject[@"errmsg"] message:@"如有问题请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.payCell.userInteractionEnabled = YES;
            }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有网络连接" message:@"请连接网络以上传照片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)submit
{
    if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        [self checkStatus];
    } else if ([AFNetworkReachabilityManager sharedManager].reachableViaWWAN) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有无线网络连接" message:@"上传照片会消耗很多流量，继续使用蜂窝数据网络上传吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有网络连接" message:@"请连接网络以上传照片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)checkStatus
{
    self.uploadCell.userInteractionEnabled = NO;
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book[@"key"]];
    [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqualToString:@"toupload"]) {
            [self uploadPhotos];
        } else if ([responseObject[@"status"] isEqualToString:@"topay"] || [responseObject[@"status"] isEqualToString:@"error"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您还未付款" message:@"请先付款，如有其他问题请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            self.uploadCell.userInteractionEnabled = YES;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片已上传过" message:@"如有其他问题请联系客服" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.uploadCell.userInteractionEnabled = YES;
    }];
}

- (void)uploadPhotos
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.operationQueue.maxConcurrentOperationCount = 1;

    self.finished = 0;

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeDeterminate;
    self.hud.labelText = @"上传中...";
    self.hud.progress = 0;
    self.navigationController.view.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;

    for (ALAsset *p in self.photos) {
        ALAssetRepresentation *rep = p.defaultRepresentation;
        NSURL *data_url = rep.url;
        NSString *uploaded_key = [NSString stringWithFormat:@"%@_uploaded", [data_url query]];
        if ([self.book[uploaded_key] isEqualToString:@"YES"]) {
            [self finishOne];
        } else {
            NSLog(@"%@", data_url);
            Byte *buffer = (Byte*)malloc((unsigned)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(unsigned)rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            NSMutableDictionary *options = [NSMutableDictionary new];
            options[@"bucket"] = @"jikangachou";
            options[@"expiration"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + 600];
            options[@"save-key"] = [NSString stringWithFormat:@"/%@/%@.JPG", self.book[@"key"], [data_url query]];
            options[@"x-gmkerl-rotate"] = @"auto";
            NSString *policy = [[NSJSONSerialization dataWithJSONObject:[options copy] options:0 error:nil] base64EncodedStringWithOptions:0];
            NSString *sig = [[NSString stringWithFormat:@"%@&DWAPWXDv2cLI7MuZmJRWq63r0T8=", policy] MD5Digest];
            NSDictionary *parameters = @{@"policy": policy, @"signature": sig};
            [manager POST:@"http://v0.api.upyun.com/jikangachou" parameters:parameters timeoutInterval:90 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:data name:@"file" fileName:@"file.JPG" mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.book[uploaded_key] = @"YES";
                [self saveBook];
                [self finishOne];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self finishOne];
                self.uploadCell.userInteractionEnabled = YES;
            }];
        }
    }
}

- (void)finishOne
{
    self.finished += 1;
    [self.hud setProgress:(1.0 * self.finished / self.photos.count)];
    if (self.finished == self.photos.count) {
        self.navigationController.view.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        if ([self checkUploadResult]) {
            NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/uploaded/", self.book[@"key"]];
            [self.jgServerManager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject[@"status"] isEqualToString:@"toprint"]) {
                    NyaruDB *db = [NyaruDB instance];
                    NyaruCollection *collection = [db collection:@"books"];
                    self.book[@"status"] = @"toprint";
                    [collection put:[self.book copy]];
                    [collection waitForWriting];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片上传完成" message:@"我们会立刻付印您的画册，约五个工作日内您就能收到相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.uploadCell.userInteractionEnabled = YES;
            }];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"部分照片没有上传成功" message:@"请重试上传，只会重试上传失败的照片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [self.hud hide:YES];
        }
    }
}

- (BOOL)checkUploadResult
{
    for (ALAsset *p in self.photos) {
        ALAssetRepresentation *rep = p.defaultRepresentation;
        NSURL *data_url = rep.url;
        NSString *uploaded_key = [NSString stringWithFormat:@"%@_uploaded", [data_url query]];
        if (![self.book[uploaded_key] isEqualToString:@"YES"]) {
            return NO;
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self checkStatus];
    }
}

@end
