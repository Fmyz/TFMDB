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
#import "MJExtension.h"
#import "TFMDBHelper+TDBModelExecute.h"

@interface ViewController ()

@property (strong, nonatomic) TestDBHelper *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _helper = [TestDBHelper helperInstance];
    
//    NSDictionary *Studentdict = @{@"sid":[NSNumber numberWithInteger:10], @"name":@"liu", @"age":[NSNumber numberWithInteger:18], @"score":[NSNumber numberWithFloat:132.f], @"cid":[NSNumber numberWithInteger:1701], @"good":[NSNumber numberWithBool:YES]};
//    Student *student = [Student mj_objectWithKeyValues:Studentdict];
//    
//    NSDictionary<NSNumber *, Student *> *studentDic = @{@(StudentTypeGood):student,@(StudentTypeWeak):student};
//    NSDictionary *Teacherdict = @{@"tid":[NSNumber numberWithInteger:101], @"name":@"liu", @"age":[NSNumber numberWithInteger:18], @"studentDic":studentDic};
//    Teacher *teacher = [Teacher mj_objectWithKeyValues:Teacherdict];
//    
//    NSArray<Teacher *> *teachers = @[teacher, teacher];
//    NSDictionary *Classesdict = @{@"cid":[NSNumber numberWithInteger:1701], @"number":[NSNumber numberWithInteger:18], @"teachers":teachers};
//    Classes *classes = [Classes mj_objectWithKeyValues:Classesdict];
//    
//    
    
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
    NSLog(@"DropTable student suc: %d", suc);
    
    suc = [_helper executeDropTable:@"classes"];
    NSLog(@"DropTable classes suc: %d", suc);
}
- (IBAction)Schema:(id)sender {
    NSString *schema = [_helper getTableSchema:@"student"];
    NSLog(@"Schema student: %@", schema);
    
    schema = [_helper getTableSchema:@"classes"];
    NSLog(@"Schema classes: %@", schema);
}

#pragma mark - Sql Model
- (IBAction)StudentCreateTable:(id)sender {
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Student class]];
    NSLog(@"StudentCreateTable suc: %d", suc);
}
- (IBAction)ClassesCreateTable:(id)sender {
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Classes class]];
    NSLog(@"ClassesCreateTable suc: %d", suc);
}
- (IBAction)TeacherCreateTable:(id)sender {
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Teacher class]];
    NSLog(@"TeacherCreateTable suc: %d", suc);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
