//
//  ViewController.m
//  TFMDBDemo
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "ViewController.h"
#import "TestDBHelper.h"

@interface ViewController ()

@property (strong, nonatomic) TestDBHelper *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _helper = [TestDBHelper helperInstance];
}

- (IBAction)CreateTable:(id)sender {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, class INTEGER);";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"CreateTable suc: %d", suc);
}
- (IBAction)CreateTables:(id)sender {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, class INTEGER);"
    "CREATE TABLE IF NOT EXISTS classes (cid INTEGER PRIMARY KEY, number INTEGER, totalscore FLOAT, averagescore FLOAT);";
    NSLog(@"sql: %@", sql);
    BOOL suc = [_helper executeStatements:sql];
    NSLog(@"CreateTables suc: %d", suc);
}
- (IBAction)InsertOne:(id)sender {
    BOOL suc = [_helper executeUpdateWithFormat:@"INSERT INTO student(name, age, score, class) values(%@, %d, %f, %d)", @"t1", 15, 134.3, 1701, nil];
    NSLog(@"InsertOne suc: %d", suc);
}
- (IBAction)InsertFormat:(id)sender {
}
- (IBAction)InsertMore:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
