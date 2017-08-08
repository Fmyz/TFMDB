//
//  NSObject+TDBModel.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDBModelDelegate.h"

@interface NSObject (TDBModel)

///创建表sql
+ (NSString *)sqlForCreateTable:(NSString *)tableName;

///插入表数据sql
- (NSString *)sqlForInsertIntoTable:(NSString *)tableName isReplace:(BOOL)isReplace;

///更新表数据sql
- (NSString *)sqlForUpdateTable:(NSString *)tableName whereSql:(NSString *)whereSql;

///查询表数据sql
+ (NSString *)sqlForSelectTable:(NSString *)tableName whereSql:(NSString *)whereSql orderbySql:(NSString *)orderbySql limitSql:(NSString *)limitSql;

///删除表数据sql
+ (NSString *)sqlForDeleteTable:(NSString *)tableName whereSql:(NSString *)whereSql;

///删除表sql
+ (NSString *)sqlForDropTable:(NSString *)tableName;

///字典转模型
+ (id)modelForKeyValue:(NSDictionary *)keyValues;

///根据表列名(全小写)转换属性名
+ (NSString *)propertyNameWithDBKey:(NSString *)dbKey;

///转换表数据的值
+ (id)propertyName:(NSString *)propertyName valueCheckIsDictionaryOrArray:(id)value;

@end



