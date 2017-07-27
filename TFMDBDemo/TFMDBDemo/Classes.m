//
//  Classes.m
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "Classes.h"
#import "MJExtension.h"
#import "NSObject+TDBModel.h"

@interface Classes () <TDBModelDelegate>

@end

@implementation Classes

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"teachers":@"Teacher"};
}

+ (NSString *)sql_tableName
{
    return @"classes";
}

@end


@implementation Teacher



@end
