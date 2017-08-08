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
    return @[@"sId"];
}

+ (NSArray *)t_dbModelNotNullPropertyNames
{
    return @[@"sId", @"name"];
}

+ (NSDictionary *)t_dbModelDefaultPropertyNamesAndValues
{
    return @{@"cid":@"1701", @"name":@"'F'"};
}

+ (NSArray *)t_dbModelUniquePropertyNames
{
    return @[@"sId"];
}

+ (NSDictionary<NSString *, NSString *> *)t_dbModelCheckPropertyNamesAndConditions
{
    return @{@"sId":@"sId > 50", @"cid":@"cid > 1700"};//value为一个条件，满足该条件，才可成功插入数据库。
}

+ (NSDictionary *)t_dbModelObjectClassInDictionary
{
    return @{@"SInfoDic":@"SInfo"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    //会忽略的属性
    return @[@"ignoreStr"];
}



@end

@implementation SInfo


@end
