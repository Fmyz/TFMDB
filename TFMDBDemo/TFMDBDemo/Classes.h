//
//  Classes.h
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Student;
@class Teacher;
@interface Classes : NSObject

@property (assign, nonatomic) NSInteger cid;
@property (copy, nonatomic) NSArray<Teacher *> *teachers;
@property (strong, nonatomic) NSDictionary<NSString *, Student *> *studentDic;

@end


@interface Teacher : NSObject

@property (copy, nonatomic) NSString *tid;
@property (strong, nonatomic) NSDictionary<NSString *, Student *> *studentDic;

@end
