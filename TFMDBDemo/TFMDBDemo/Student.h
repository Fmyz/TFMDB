//
//  Student.h
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (assign, nonatomic) NSInteger sid;    //学号
@property (copy, nonatomic) NSString *name;     //姓名
@property (assign, nonatomic) NSInteger age;    //年龄
@property (assign, nonatomic) float score;      //分数
@property (assign, nonatomic) NSInteger cid;    //班级id

@end
