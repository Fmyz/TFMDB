//
//  NSObject+TDBModel.m
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "NSObject+TDBModel.h"
#import "TDBModelUtils.h"

#import "MJExtension.h"

@implementation NSObject (TDBModel)

+ (NSString *)sqlForCreateTable:(NSString *)tableName
{
    NSString *sql = nil;
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return nil;
    }
    
    NSArray<NSString *> *ivarNames = [self getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return nil;
    }
    
    NSArray *primaryKeyPropertyNames = [self t_primaryKeyPropertyNames];
    NSArray *autoIncrementPropertyNames = [self t_autoIncrementPropertyNames];
    
    sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];
    NSInteger count = MIN(propertys.count, ivarNames.count);
    
    NSMutableArray<NSString *> *columns = [NSMutableArray array];
    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        
        NSString *sqlType = [self sqlTypeWithProperty:property];
        if (!sqlType) {
            continue;
        }
        
        NSString *name = property.name;
        NSString *column = [name stringByAppendingString:@" "];
        column = [column stringByAppendingString:sqlType];
        
        if ([primaryKeyPropertyNames containsObject:name]) {
            column = [column stringByAppendingString:tSql_Attribute_PrimaryKey];
            column = [column stringByAppendingString:@" "];
        }
        
        if ([autoIncrementPropertyNames containsObject:name]) {
            column = [column stringByAppendingString:tSql_Attribute_AutoIncrement];
        }
        
        [columns addObject:column];
    }
    
    if (columns.count) {
        NSString *sqlColumn = [columns componentsJoinedByString:@", "];
        sql = [sql stringByAppendingString:sqlColumn];
    }
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
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

+ (NSArray<NSString *> *)getClassIvarNames
{
    NSMutableArray<NSString *> *ivarNames = [NSMutableArray array];
    
    NSArray *allowedPropertyNames = [self mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [self mj_totalIgnoredPropertyNames];
    
    unsigned int count;
    Ivar *ivar = class_copyIvarList(self, &count);
    for (int i=0; i<count; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *ivarName = [NSString stringWithUTF8String:name];
        NSString *propertyName = [self replaceFirstUnderline:ivarName];
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:propertyName]) continue;
        if ([ignoredPropertyNames containsObject:propertyName]) continue;
        
        [ivarNames addObject:propertyName];
    }
    free(ivar);
    
    return [ivarNames copy];
}

+ (NSString *)sqlTypeWithProperty:(MJProperty *)property
{
    MJPropertyType *type = property.type;
    NSString *sqlType = nil;
    if (type.isBoolType) {
        sqlType = tSql_Type_Blob;
    } else if (type.isNumberType) {
        NSString *code = type.code;
        if ([code isEqualToString:@"f"]) {
            sqlType = tSql_Type_Float;
        } else if ([code isEqualToString:@"d"]) {
            sqlType = tSql_Type_Double;
        } else if ([code isEqualToString:@"i"] || [code isEqualToString:@"s"]) {
            sqlType = tSql_Type_Int;
        } else if ([code isEqualToString:@"l"] || [code isEqualToString:@"q"] || [code isEqualToString:@"I"] || [code isEqualToString:@"Q"]) {
            sqlType = tSql_Type_Integer;
        }
    } else if (type.isFromFoundation || type.isIdType) {
        sqlType = tSql_Type_Text;
    }
    return sqlType;
}

#pragma mark - 表名
+ (NSString *)t_tableName
{
    NSString *t_tableName = nil;
    if ([self respondsToSelector:@selector(t_dbModelTableName)]) {
        t_tableName = [self performSelector:@selector(t_dbModelTableName)];
    }
    return t_tableName;
}

#pragma mark - 主键
+ (NSArray *)t_primaryKeyPropertyNames
{
    NSArray *t_primaryKeyPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModePrimaryKeyPropertyNames)]) {
        t_primaryKeyPropertyNames = [self performSelector:@selector(t_dbModePrimaryKeyPropertyNames)];
    }
    return t_primaryKeyPropertyNames;
}


#pragma mark - 自增
+ (NSArray *)t_autoIncrementPropertyNames
{
    NSArray *t_autoIncrementPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModeAutoIncrementPropertyNames)]) {
        t_autoIncrementPropertyNames = [self performSelector:@selector(t_dbModeAutoIncrementPropertyNames)];
    }
    return t_autoIncrementPropertyNames;
}

+ (NSString *)replaceFirstUnderline:(NSString *)ivarName
{
    // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
    // 比如 @property(retain) NSString *abc;则 key == _abc;
    NSString *propertyName = ivarName;
    
    NSString *firstStr = [ivarName substringToIndex:1];
    if ([firstStr isEqualToString:@"_"]) {
        propertyName = [ivarName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    
    return propertyName;
}

@end
