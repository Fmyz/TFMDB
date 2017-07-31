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

+ (NSDictionary *)t_dbModelObjectClassInDictionary
{
    return @{@"SInfoDic":@"SInfo"};
}

+ (NSArray *)t_dbModelPrimaryKeyPropertyNames
{
    return @[@"sId"];
}

+ (NSArray *)mj_ignoredPropertyNames
{
    //会忽略的属性
    return @[@"ignoreStr"];
}

@end

@implementation SInfo


@end
