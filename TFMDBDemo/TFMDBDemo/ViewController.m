//
//  ViewController.m
//  TFMDBDemo
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "ViewController.h"
#import "TestDBHelper.h"
#import "Student.h"
#import "Classes.h"

//#import "NSObject+TDBModel.h"

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
    NSString *sql = @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, cid INTEGER);";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"CreateTable suc: %d", suc);
}
- (IBAction)CreateTables:(id)sender {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, cid INTEGER, cname TEXT);"
    "CREATE TABLE IF NOT EXISTS classes (cid INTEGER PRIMARY KEY, teacher TEXT, number INTEGER);";
    NSLog(@"sql: %@", sql);
    BOOL suc = [_helper executeStatements:sql];
    NSLog(@"CreateTables suc: %d", suc);
}
- (IBAction)InsertOne:(id)sender {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO student(name, age, score, cid) values('%@', %d, %f, %d)", @"s1001", 14, 127.3, 1702];
    
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"InsertOne suc: %d", suc);
}
- (IBAction)InsertFormat:(id)sender {
    
    BOOL suc = [_helper executeUpdateWithFormat:@"INSERT INTO student(name, age, score, cid) values(?, ?, ?, ?)", @"s1002", [NSNumber numberWithInteger:15], [NSNumber numberWithFloat:134.3], [NSNumber numberWithInteger:1701], nil];
    NSLog(@"InsertFormat suc: %d", suc);
}
- (IBAction)InsertMore:(id)sender {
}
- (IBAction)DropTable:(id)sender {
    BOOL suc = [_helper executeDropTable:@"student"];
    NSLog(@"DropTable suc: %d", suc);
}
- (IBAction)Schema:(id)sender {
    NSString *schema = [_helper getTableSchema:@"student"];
    NSLog(@"Schema student: %@", schema);
    
    schema = [_helper getTableSchema:@"classes"];
    NSLog(@"Schema classes: %@", schema);
}

#pragma mark - Sql Model
- (IBAction)ModelCreateTable:(id)sender {
//    [Student sqlCreateTable:@"student" dbHelper:_helper];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
