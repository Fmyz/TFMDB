//
//  NSObject+TDBModel.m
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "NSObject+TDBModel.h"
#import "MJExtension.h"

static const char TPrimaryKeyPropertyNamesKey = '\0';
static const char TAutoIncrementPropertyNamesKey = '\0';

static NSMutableDictionary *primaryKeyPropertyNamesDict_;
static NSMutableDictionary *autoIncrementPropertyNames_;

@implementation NSObject (TDBModel)

+ (void)load
{
    primaryKeyPropertyNamesDict_ = [NSMutableDictionary dictionary];
    autoIncrementPropertyNames_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized (self) {
        if (key == &TPrimaryKeyPropertyNamesKey) return primaryKeyPropertyNamesDict_;
        if (key == &TAutoIncrementPropertyNamesKey) return autoIncrementPropertyNames_;
        return nil;
    }
}

+ (BOOL)sqlCreateTable:(NSString *)tableName dbHelper:(TFMDBHelper *)dbHelper
{
    NSArray *allowedCodingPropertyNames = [self mj_totalAllowedPropertyNames];
    NSArray *ignoredCodingPropertyNames = [self mj_totalIgnoredPropertyNames];
    
    NSArray *primaryKeyPropertyNames = [self t_primaryKeyPropertyNames];
    NSArray *autoIncrementPropertyNames = [self t_autoIncrementPropertyNames];
    
    [self mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
    }];
    
    return YES;
}


#pragma mark - 属性主键配置
+ (NSMutableArray *)t_primaryKeyPropertyNames
{
    return [self t_totalObjectsWithSelector:@selector(sql_primaryKeyPropertyNames) key:&TPrimaryKeyPropertyNamesKey];
}

#pragma mark - 属性自增配置
+ (NSMutableArray *)t_autoIncrementPropertyNames
{
    return [self t_totalObjectsWithSelector:@selector(sql_autoIncrementPropertyNames) key:&TAutoIncrementPropertyNamesKey];
}

+ (NSMutableArray *)t_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [self dictForKey:key][NSStringFromClass(self)];
    if (array) return array;
    
    // 创建、存储
    [self dictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}


@end
