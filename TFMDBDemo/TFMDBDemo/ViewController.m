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

#import "FMResultSet.h"

@interface ViewController ()

@property (strong, nonatomic) TestDBHelper *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _helper = [TestDBHelper helperInstance];
}

- (IBAction)SQLCreateTableStudent:(id)sender {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, cid INTEGER, good BLOB);";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLCreateTableStudent suc: %d", suc);
}
- (IBAction)SQLStudentInsertOne:(id)sender {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO student(name, age, score, cid, good) values('%@', %d, %f, %d, %d)", @"s1001", 14, 127.3, 1702, YES];
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLStudentInsertOne suc: %d", suc);
}
- (IBAction)SQLStudentInsertFormat:(id)sender {
    BOOL suc = [_helper executeUpdateWithFormat:@"INSERT INTO student(name, age, score, cid, good) values(?, ?, ?, ?, ?)", @"s1002", [NSNumber numberWithInteger:15], [NSNumber numberWithFloat:134.3], [NSNumber numberWithInteger:1701], [NSNumber numberWithBool:NO], nil];
    NSLog(@"SQLStudentInsertFormat suc: %d", suc);
}
- (IBAction)SQLStudentInsertMore:(id)sender {
    NSInteger number = 1000;
    
    NSMutableArray *mores1 = [NSMutableArray array];
    NSMutableArray *mores2 = [NSMutableArray array];
    
    for (NSInteger index = 0; index < number; index++) {
        
        NSString *name = [NSString stringWithFormat:@"s%ld", (long)index];
        NSInteger age = arc4random()%19 + 10;
        CGFloat score = (100 + arc4random()%1400)/10.f;
        
        NSInteger cid = (index < number / 3)?1701:(index<number/3*2)?1702:1703;
        BOOL good = (arc4random()%10 > 5);
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO student(name, age, score, cid, good) values('%@', %ld, %.2f, %ld, %d)", name, (long)age, score, (long)cid, good];
        
        if (index < number / 2) {
            [mores1 addObject:sql];
        } else {
            [mores2 addObject:sql];
        }
    }
    
    NSDate *date1 = [NSDate date];
    //    [_helper executeTransaction:mores1 progress:^(NSInteger curIndex, NSInteger totalCount, NSString *errorMsg) {
    //        if (errorMsg) {
    //            NSLog(@"curIndex:%ld totalCount:%ld", (long)curIndex, (long)totalCount);
    //        }
    //    }];
    for (NSString *sql in mores1) {
        BOOL suc = [_helper executeUpdate:sql];
        if (!suc) {
            NSLog(@"executeUpdate suc:%d, sql:%@", suc, sql);
            break;
        }
    }
    NSDate *date2 = [NSDate date];
    NSTimeInterval a = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"不使用事务插入500条数据用时%.3f秒",a);
    
    
    [_helper executeTransaction:mores2 progress:^(NSInteger curIndex, NSInteger totalCount, NSString *errorMsg) {
        if (errorMsg) {
            NSLog(@"curIndex:%ld totalCount:%ld", (long)curIndex, (long)totalCount);
        }
    }];
    //    for (NSString *sql in mores2) {
    //        BOOL suc = [_helper executeUpdate:sql];
    //        if (!suc) {
    //            NSLog(@"executeUpdate suc:%d, sql:%@", suc, sql);
    //            break;
    //        }
    //    }
    NSDate *date3 = [NSDate date];
    NSTimeInterval b = [date3 timeIntervalSince1970] - [date2 timeIntervalSince1970];
    NSLog(@"使用事务插入500条数据用时%.3f秒",b);
}
- (IBAction)SQLStudentSelect:(id)sender {
    
    NSString *sql = @"SELECT * FROM student WHERE name = 's1001' LIMIT 1";
    [_helper executeQuery:sql complete:^(FMResultSet *rs) {
       
        NSInteger sid = [[rs objectForColumn:@"sid"] integerValue];
        NSString *name = [rs objectForColumn:@"name"];
        NSInteger age = [[rs objectForColumn:@"age"] integerValue];
        float score = [[rs objectForColumn:@"score"] floatValue];
        NSInteger cid = [[rs objectForColumn:@"cid"] integerValue];
        BOOL good = [[rs objectForColumn:@"good"] boolValue];

        NSLog(@"SQLStudentSelect{sid:%ld, name:%@, age:%ld, score:%f, cid:%ld, good:%d}", (long)sid, name, (long)age, score, (long)cid, good);
    }];
}
- (IBAction)SQLStudentDelete:(id)sender {
    NSString *sql = @"DELETE * FROM student WHERE name = 's1001'";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLStudentDelete suc: %d", suc);
}
- (IBAction)SQLStudentDrop:(id)sender {
    NSString *sql = @"DROP TABLE IF EXISTS student";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLStudentDrop suc: %d", suc);
}
- (IBAction)SQLCreateTableStudentAndClasses:(id)sender {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS student (sid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, score FLOAT, cid INTEGER, good BLOB);"
    "CREATE TABLE IF NOT EXISTS classes (cid INTEGER PRIMARY KEY, teachers TEXT, number INTEGER, studentDic TEXT);";
    NSLog(@"SQLCreateTableStudentAndClasses sql: %@", sql);
    BOOL suc = [_helper executeStatements:sql];
    NSLog(@"SQLCreateTableStudentAndClasses suc: %d", suc);
}
- (IBAction)SQLClassesInsert:(id)sender {
    NSDictionary *teacherDict = @{@"tid":[NSNumber numberWithInteger:101], @"name":@"liu", @"age":[NSNumber numberWithInteger:18]};
    NSArray<NSDictionary *> *teachers = @[teacherDict, teacherDict];
    NSString *teachersJsonStr = [teachers mj_JSONString];
    
    NSDictionary *studentDict = @{@"sid":[NSNumber numberWithInteger:1222], @"name":@"Tan", @"age":[NSNumber numberWithInteger:17], @"score":[NSNumber numberWithFloat:136.f], @"cid":[NSNumber numberWithInteger:1701], @"good":[NSNumber numberWithBool:YES]};
    NSDictionary *studentDic = @{[NSString stringWithFormat:@"%ld", (long)StudentTypeGood]:studentDict, [NSString stringWithFormat:@"%ld", (long)StudentTypeWeak]:studentDict};
    NSString *studentDicJsonStr = [studentDic mj_JSONString];
    
    BOOL suc = [_helper executeUpdateWithFormat:@"INSERT INTO classes(cid, teachers, number, studentDic) values(?, ?, ?, ?)", [NSNumber numberWithInteger:1701], teachersJsonStr, [NSNumber numberWithInteger:40], studentDicJsonStr, nil];
    NSLog(@"SQLClassesInsert suc: %d", suc);
    
}
- (IBAction)SQLClassesSelect:(id)sender {
    NSString *sql = @"SELECT * FROM classes WHERE cid = 1701 LIMIT 1";
    [_helper executeQuery:sql complete:^(FMResultSet *rs) {
        NSInteger cid = [[rs objectForColumn:@"cid"] integerValue];
        NSString *teachers = [rs objectForColumn:@"teachers"];
        NSInteger number = [[rs objectForColumn:@"number"] integerValue];
        NSString *studentDic = [rs objectForColumn:@"studentDic"];
        NSLog(@"SQLClassesSelect{cid:%ld\nteachers:%@\nnumber:%ld\nstudentDic:%@}", (long)cid, teachers, (long)number, studentDic);
    }];
}
- (IBAction)SQLSchema:(id)sender {
    NSString *schema = [_helper getTableSchema:@"student"];
    NSLog(@"SQLSchema student: %@", schema);
    
    schema = [_helper getTableSchema:@"classes"];
    NSLog(@"SQLSchema classes: %@", schema);
}

#pragma mark - Sql Model
- (IBAction)StudentCreateTable:(id)sender {
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Student class]];
    NSLog(@"StudentCreateTable suc: %d", suc);
}
- (IBAction)StudentInsertTable:(id)sender {
    
    //主键唯一， 第二次会失败
    NSDictionary *studentDict = @{@"sid":[NSNumber numberWithInteger:1111], @"name":@"liu", @"age":[NSNumber numberWithInteger:18], @"score":[NSNumber numberWithFloat:132.f], @"cid":[NSNumber numberWithInteger:1701], @"good":[NSNumber numberWithBool:YES]};
    Student *student = [Student mj_objectWithKeyValues:studentDict];
    
    BOOL suc = [_helper executeInsertIntoTable:nil model:student];
    NSLog(@"StudentInsertTable suc: %d", suc);
}
- (IBAction)StudentReplaceTable:(id)sender {
    NSDictionary *studentDict = @{@"sid":[NSNumber numberWithInteger:1111], @"name":@"s1111", @"age":[NSNumber numberWithInteger:18], @"score":[NSNumber numberWithFloat:131.f], @"cid":[NSNumber numberWithInteger:1701], @"good":[NSNumber numberWithBool:NO]};
    Student *student = [Student mj_objectWithKeyValues:studentDict];
    
    BOOL suc = [_helper executeReplaceIntoTable:nil model:student];
    NSLog(@"StudentReplaceTable suc: %d", suc);
}
- (IBAction)StudentUpdateTable:(id)sender {
    NSDictionary *studentDict = @{@"sid":[NSNumber numberWithInteger:1111], @"name":@"LT"};
    Student *student = [Student mj_objectWithKeyValues:studentDict];
    
    //    BOOL suc = [_helper executeUpdateTable:nil model:student whereSql:@"name = 's1111'"];
    BOOL suc = [_helper executeUpdateTable:nil model:student whereSql:nil];
    NSLog(@"StudentUpdateTable suc: %d", suc);
}
- (IBAction)StudentSelect:(id)sender {
    NSInteger count = [_helper executeSelectRowCountFromTable:@"student"];
    NSLog(@"StudentSelect SelectRowCount: %ld", (long)count);
    
    ////desc降序 asc升序
    NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:@"cid = 1701" orderbySql:@"score DESC" limitSql:@"5"];
    //    NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:nil orderbySql:nil limitSql:nil];
    
    NSLog(@"StudentSelect executeSelectTable count: %lu", (unsigned long)students.count);
    
    for (Student *student in students) {
        NSLog(@"StudentSelect{sid:%ld, name:%@, age:%ld, score:%.2f, cid:%ld, good:%d}", (long)student.sid, student.name, (long)student.age, student.score, (long)student.cid, student.good);
    }
}
- (IBAction)StudentDelete:(id)sender {
    BOOL suc = [_helper executeDeleteTable:nil modelClass:[Student class] whereSql:@"cid = 1703"];
    NSLog(@"StudentDelete suc: %d", suc);
}
- (IBAction)StudentDrop:(id)sender {
    BOOL suc = [_helper executeDropTable:nil modelClass:[Student class]];
    NSLog(@"StudentDrop suc: %d", suc);
}
- (IBAction)ClassesCreateTable:(id)sender {
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Classes class]];
    NSLog(@"ClassesCreateTable suc: %d", suc);
}
- (IBAction)ClassesInsertTable:(id)sender {
    NSDictionary *Studentdict = @{@"sid":[NSNumber numberWithInteger:1223], @"name":@"Tan", @"age":[NSNumber numberWithInteger:17], @"score":[NSNumber numberWithFloat:136.f], @"cid":[NSNumber numberWithInteger:1701], @"good":[NSNumber numberWithBool:YES]};
    Student *student = [Student mj_objectWithKeyValues:Studentdict];
    
    NSDictionary<NSNumber *, Student *> *studentDic = @{[NSString stringWithFormat:@"%ld", (long)StudentTypeGood]:student,[NSString stringWithFormat:@"%ld", (long)StudentTypeWeak]:student};
    NSDictionary *Teacherdict = @{@"tid":[NSNumber numberWithInteger:101], @"name":@"liu", @"age":[NSNumber numberWithInteger:18]};
    Teacher *teacher = [Teacher mj_objectWithKeyValues:Teacherdict];
    
    NSArray<Teacher *> *teachers = @[teacher, teacher];
    NSDictionary *Classesdict = @{@"cid":[NSNumber numberWithInteger:1701], @"number":[NSNumber numberWithInteger:18], @"teachers":teachers, @"studentDic":studentDic};
    Classes *classes = [Classes mj_objectWithKeyValues:Classesdict];
    
    BOOL suc = [_helper executeInsertIntoTable:nil model:classes];
    NSLog(@"StudentInsertTable suc: %d", suc);
}

- (IBAction)ClassesSelect:(id)sender {
    NSInteger count = [_helper executeSelectRowCountFromTable:@"classes"];
    NSLog(@"ClassesSelect SelectRowCount: %ld", (long)count);
    
    ////desc降序 asc升序
    NSArray<Classes *> *classes = [_helper executeSelectTable:nil modelClass:[Classes class] whereSql:@"cid = 1701" orderbySql:nil limitSql:@"1"];
    //    NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:nil orderbySql:nil limitSql:nil];
    
    NSLog(@"ClassesSelect executeSelectTable count: %lu", (unsigned long)classes.count);
    
    for (Classes *class in classes) {
        NSLog(@"ClassesSelect{cid:%ld, teachers:%@, number:%ld, studentDic:%@}", (long)class.cid, class.teachers, (long)class.number, class.studentDic);
    }
}

- (IBAction)ClassesDrop:(id)sender {
    BOOL suc = [_helper executeDropTable:nil modelClass:[Classes class]];
    NSLog(@"ClassesDrop suc: %d", suc);    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
