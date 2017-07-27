//
//  Classes.h
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StudentType) {

    StudentTypeWeak = 0,
    StudentTypeGood,

};

@class Student;
@class Teacher;
@interface Classes : NSObject

@property (assign, nonatomic) NSInteger cid;    //班级id
@property (copy, nonatomic) NSArray<Teacher *> *teachers;   //老师
@property (assign, nonatomic) NSInteger number;   //人数

@end


@interface Teacher : NSObject

@property (copy, nonatomic) NSString *tid;      //教师id
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) int age;
@property (strong, nonatomic) NSDictionary<NSNumber *, Student *> *studentDic;

@end
