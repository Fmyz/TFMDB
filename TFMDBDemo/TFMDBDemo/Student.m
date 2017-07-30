//
//  Student.m
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "Student.h"
#import "NSObject+TDBModel.h"

@implementation Student

+ (NSString *)t_dbModelTableName
{
    return @"student";
}

+ (NSArray *)t_dbModelPrimaryKeyPropertyNames
{
    return @[@"sid"];
}

+ (NSArray *)t_dbModelAutoIncrementPropertyNames
{
    return @[@"sid"];
}

+ (NSArray *)mj_ignoredPropertyNames
{
    //创建表的时候会忽略的属性
    return @[@"ignoreStr"];
}

//+ (NSArray *)mj_allowedPropertyNames
//{
//
//}

@end
