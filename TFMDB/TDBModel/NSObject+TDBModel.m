//
//  NSObject+TDBModel.m
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "NSObject+TDBModel.h"
#import "TFMDBHelper.h"
#import "TDBModelUtils.h"

#import "MJExtension.h"

@implementation NSObject (TDBModel)


+ (BOOL)sqlCreateTable:(NSString *)tableName dbHelper:(TFMDBHelper *)dbHelper
{
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }

    if (!tableName || !tableName.length) {
        return NO;
    }
    
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return NO;
    }
    
    NSArray *primaryKeyPropertyNames = [self t_primaryKeyPropertyNames];
    NSArray *autoIncrementPropertyNames = [self t_autoIncrementPropertyNames];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", tableName];
    for (NSInteger index = 0; index < propertys.count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        
        if (index == 0) {
            sql = [sql stringByAppendingString:@"("];
        }
        
        NSString *name = property.name;
        [self sqlTypeWithProperty:property];
        
        
        if (index == propertys.count - 1) {
            sql = [sql stringByAppendingString:@")"];
        }
        
    }
    
    BOOL suc = [dbHelper executeUpdate:sql];
    
    return suc;
}

+ (NSArray *)getClassMJPropertys
{
    __block NSMutableArray<MJProperty *> *propertys = [NSMutableArray array];
    
    NSArray *allowedPropertyNames = [self mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [self mj_totalIgnoredPropertyNames];
    [self mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
        if ([ignoredPropertyNames containsObject:property.name]) return;
        
        [propertys addObject:property];
    }];
    
    return [propertys copy];
}

+ (NSString *)sqlTypeWithProperty:(MJProperty *)property
{
    MJPropertyType *type = property.type;
    Class propertyClass = type.typeClass;
    
    
//    [arr mj_JSONString];
    
    NSString *sqlType = nil;
    if (type.isBoolType) {
        sqlType = tSql_Type_Blob;
    } else if (type.isNumberType) {
    
    }
    
    
//
//    if ([firstType isEqualToString:@"f"]) {
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.floatValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"i"]){
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.intValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"d"]){
//        [model setValue:[rs objectForColumnName:columnName] forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"l"] || [firstType isEqualToString:@"q"]){
//        [model setValue:[rs objectForColumnName:columnName] forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"c"] || [firstType isEqualToString:@"B"]){
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.boolValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"s"]){
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.shortValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"I"]){
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.integerValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"Q"]){
//        NSNumber *number = [rs objectForColumnName:columnName];
//        [model setValue:@(number.unsignedIntegerValue) forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"@\"NSData\""]){
//        NSData *value = [rs dataForColumn:columnName];
//        [model setValue:value forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"@\"NSDate\""]){
//        NSDate *value = [rs dateForColumn:columnName];
//        [model setValue:value forKey:propertyName];
//        
//    } else if([firstType isEqualToString:@"@\"NSString\""]){
//        NSString *value = [rs stringForColumn:columnName];
//        [model setValue:value forKey:propertyName];
//        
//    } else {
//        [model setValue:[rs objectForColumnName:columnName] forKey:propertyName];
//    }
//    
    return sqlType;
}

#pragma mark - 表名
+ (NSString *)t_tableName
{
    NSString *t_tableName = nil;
    if ([self respondsToSelector:@selector(sql_tableName)]) {
        t_tableName = [self performSelector:@selector(sql_tableName)];
    }
    return t_tableName;
}

#pragma mark - 主键
+ (NSArray *)t_primaryKeyPropertyNames
{
    NSArray *t_primaryKeyPropertyNames = nil;
    if ([self respondsToSelector:@selector(sql_primaryKeyPropertyNames)]) {
        t_primaryKeyPropertyNames = [self performSelector:@selector(sql_primaryKeyPropertyNames)];
    }
    return t_primaryKeyPropertyNames;
}


#pragma mark - 自增
+ (NSArray *)t_autoIncrementPropertyNames
{
    NSArray *t_autoIncrementPropertyNames = nil;
    if ([self respondsToSelector:@selector(sql_autoIncrementPropertyNames)]) {
        t_autoIncrementPropertyNames = [self performSelector:@selector(sql_autoIncrementPropertyNames)];
    }
    return t_autoIncrementPropertyNames;
}

@end
