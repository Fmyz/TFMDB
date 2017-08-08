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
    
    self.title = @"DB SQL";
}

- (IBAction)SQLCreateTableStudent:(id)sender {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS student (sId INTEGER PRIMARY KEY, name TEXT, SInfoDic TEXT, cid INTEGER);";
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLCreateTableStudent suc: %d", suc);
}
- (IBAction)SQLStudentInsertOne:(id)sender {
    
    NSInteger sid = 1000 + arc4random() % 1000;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO student(sId, name, cid) values(%ld, '%@', %d)", (long)sid, @"s1001", 1701];
    BOOL suc = [_helper executeUpdate:sql];
    NSLog(@"SQLStudentInsertOne suc: %d", suc);
}
- (IBAction)SQLStudentInsertFormat:(id)sender {
    NSInteger sid = 1000 + arc4random() % 1000;
    BOOL suc = [_helper executeUpdateWithFormat:@"INSERT INTO student(sId, name, cid) values(?, ?, ?)", [NSNumber numberWithInteger:sid], @"s1002", [NSNumber numberWithInteger:1701], nil];
    NSLog(@"SQLStudentInsertFormat suc: %d", suc);
}
- (IBAction)SQLStudentInsertMore:(id)sender {
    NSInteger number = 1000;
    
    NSMutableArray *mores1 = [NSMutableArray array];
    NSMutableArray *mores2 = [NSMutableArray array];
    
    
    for (NSInteger index = 0; index < number; index++) {
        NSInteger cid = (index < number / 3)?1701:(index<number/3*2)?1702:1703;
        NSString *name = [NSString stringWithFormat:@"s%ld", (long)index];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO student(sId, name, cid) values(%ld, '%@', %ld)", (long)index, name, (long)cid];
        
        if (index < number / 2) {
            [mores1 addObject:sql];
        } else {
            [mores2 addObject:sql];
        }
    }
    
    NSDate *date1 = [NSDate date];
    for (NSString *sql in mores1) {
        BOOL suc = [_helper executeUpdate:sql];
        if (!suc) {
            NSLog(@"SQLStudentInsertMore suc:%d, sql:%@", suc, sql);
            break;
        }
    }
    NSDate *date2 = [NSDate date];
    NSTimeInterval a = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"不使用事务插入500条数据用时%.3f秒",a);
    
    
    [_helper executeTransaction:mores2 progress:^(NSInteger curIndex, NSInteger totalCount, NSString *errorMsg) {
        if (errorMsg) {
            NSLog(@"SQLStudentInsertMore curIndex:%ld totalCount:%ld", (long)curIndex, (long)totalCount);
        }
    }];
    NSDate *date3 = [NSDate date];
    NSTimeInterval b = [date3 timeIntervalSince1970] - [date2 timeIntervalSince1970];
    NSLog(@"使用事务插入500条数据用时%.3f秒",b);
}
- (IBAction)SQLCreateTableStudentAndClasses:(id)sender {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS student (sId INTEGER PRIMARY KEY, name TEXT, SInfoDic TEXT, cid INTEGER);"
    "CREATE TABLE IF NOT EXISTS classes (cid INTEGER PRIMARY KEY, teachers TEXT, studentDic TEXT);";
    NSLog(@"SQLCreateTableStudentAndClasses sql: %@", sql);
    BOOL suc = [_helper executeStatements:sql];
    NSLog(@"SQLCreateTableStudentAndClasses suc: %d", suc);
}
- (IBAction)SQLSchema:(id)sender {
    NSString *schema = [_helper getTableSchema:@"student"];
    NSLog(@"SQLSchema student: %@", schema);
    
    schema = [_helper getTableSchema:@"classes"];
    NSLog(@"SQLSchema classes: %@", schema);
}

#pragma mark - Sql Model
- (IBAction)StudentCreateTable:(id)sender {
    //如果没有实现t_dbModelTableName，需要带上tablename
    BOOL suc = [_helper executeCreateTable:nil modelClass:[Student class]];
    NSLog(@"StudentCreateTable suc: %d", suc);
}
- (IBAction)StudentInsertTable:(id)sender {
    Student *student = [self getOneStudent];
    static NSInteger sid = 1004;
    student.sId = sid;
    sid++;
    BOOL suc = [_helper executeInsertIntoTable:nil model:student];
    NSLog(@"StudentInsertTable suc: %d", suc);
}
- (IBAction)StudentReplaceTable:(id)sender {
    
    Student *student = [self getOneStudent];
    student.sId = 1004;
    BOOL suc = [_helper executeReplaceIntoTable:nil model:student];
    NSLog(@"StudentReplaceTable suc: %d", suc);
}
- (IBAction)StudentUpdateTable:(id)sender {
    Student *student = [self getOneStudent];
    student.sId = 1004;//会根据主键去更新
    BOOL suc = [_helper executeUpdateTable:nil model:student whereSql:nil];
    NSLog(@"StudentUpdateTable suc: %d", suc);
}
- (IBAction)StudentSelect:(id)sender {
    NSInteger count = [_helper executeSelectRowCountFromTable:@"student"];
    NSLog(@"StudentSelect SelectRowCount: %ld", (long)count);
    
    ////desc降序 asc升序
    NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:@"cid = 1701" orderbySql:@"sId DESC" limitSql:@"2"];
    //    NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:nil orderbySql:nil limitSql:nil];
    NSLog(@"StudentSelect executeSelectTable count: %lu", (unsigned long)students.count);
    for (Student *student in students) {
        NSLog(@"StudentSelect{sid:%ld, name:%@, SInfoDic:%@, cid:%ld}", (long)student.sId, student.name, student.SInfoDic, (long)student.cid);
    }
}
- (IBAction)StudentDelete:(id)sender {
    BOOL suc = [_helper executeDeleteTable:nil modelClass:[Student class] whereSql:nil];
//    BOOL suc = [_helper executeDeleteTable:nil modelClass:[Student class] whereSql:@"cid = 1701"];
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
    
    Classes *classes = [self getOneClasses];
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
        NSLog(@"ClassesSelect{cid:%ld, teachers:%@, studentDic:%@}", (long)class.cid, class.teachers, class.studentDic);
    }
}

- (IBAction)ClassesDrop:(id)sender {
    BOOL suc = [_helper executeDropTable:nil modelClass:[Classes class]];
    NSLog(@"ClassesDrop suc: %d", suc);    
}

- (Student *)getOneStudent
{
    NSInteger sid = 2000 + arc4random() % 1000;
    SInfo *sinfo1 = [self getOneSInfo];
    sinfo1.sId = sid;
    
    SInfo *sinfo2 = [self getOneSInfo];
    sinfo2.sId = sid + 1;
    
    NSInteger scid = 1701;
    
    NSDictionary<NSString *, SInfo *> *SInfoDic = @{[NSString stringWithFormat:@"%ld", (long)sid] : sinfo1, [NSString stringWithFormat:@"%ld", (long)sid+1] : sinfo2};
    NSString *name = [NSString stringWithFormat:@"s%ld", (long)sid];
    NSDictionary *sdict = @{@"sId":[NSNumber numberWithInteger:sid], @"name":name, @"SInfoDic":SInfoDic, @"ignoreStr":@"ignoreColumn", @"cid":[NSNumber numberWithInteger:scid]};
    Student *student = [Student mj_objectWithKeyValues:sdict];
    return student;
}

- (Classes *)getOneClasses
{
    static NSInteger cid = 1700;
    cid++;

    NSArray<Teacher *> *teachers = @[[self getOneTeacher], [self getOneTeacher]];
    
    Student *student1 = [self getOneStudent];
    Student *student2 = [self getOneStudent];
    NSDictionary<NSString *, Student *> *studentDic = @{student1.name:student1 , student2.name:student2};
    
    NSDictionary *cdict = @{@"cid":[NSNumber numberWithInteger:cid], @"teachers":teachers, @"studentDic":studentDic};
    Classes *classes = [Classes mj_objectWithKeyValues:cdict];
    
    return classes;
}

- (Teacher *)getOneTeacher
{
    NSInteger tid = 100 + arc4random() % 100;

    Student *student1 = [self getOneStudent];
    Student *student2 = [self getOneStudent];
    NSDictionary<NSString *, Student *> *studentDic = @{student1.name:student1 , student2.name:student2};
    
    NSDictionary *tdict = @{@"tid":[NSNumber numberWithInteger:tid], @"studentDic":studentDic};
    Teacher *teacher = [Teacher mj_objectWithKeyValues:tdict];
    
    return teacher;
}

- (SInfo *)getOneSInfo
{
    SInfo *sinfo = [[SInfo alloc] init];
    sinfo.age = 9 + arc4random()%18;
    return sinfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
