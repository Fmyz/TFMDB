//
//  RootViewController.m
//  TFMDBDemo
//
//  Created by Fmyz on 2017/8/8.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "RootViewController.h"

#import "TestDBHelper.h"
#import "TFMDBHelper+SQLCipher.h"

@interface RootViewController ()

@property (copy, nonatomic) NSString *password;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"DB Cipher";
}
- (IBAction)EncryptDatabase:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *dbPath = [directory stringByAppendingPathComponent:@"test.db"];
    
    NSString *password = @"YourPassword";
    self.password = password;
    
    BOOL suc = [TestDBHelper encryptDatabase:dbPath password:password];
    NSLog(@"EncryptDatabase suc: %d", suc);
}
- (IBAction)unEncryptDatabase:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *dbPath = [directory stringByAppendingPathComponent:@"test.db"];
    
    BOOL suc = [TestDBHelper unEncryptDatabase:dbPath password:self.password];
    NSLog(@"unEncryptDatabase suc: %d", suc);
    
    if (suc) {
        self.password = nil;
    }
}

- (IBAction)enterOpenDB:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *dbPath = [directory stringByAppendingPathComponent:@"test.db"];
    
    TestDBHelper *helper = [TestDBHelper helperInstance];
    BOOL suc = [helper openDB:dbPath password:self.password];
    NSLog(@"openDB suc: %d password:%@\npath:%@", suc, self.password, dbPath);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
