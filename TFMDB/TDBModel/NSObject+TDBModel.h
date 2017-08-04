//
//  NSObject+TDBModel.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface NSObject (TDBModel)

+ (NSString *)sqlForCreateTable:(NSString *)tableName;

- (NSString *)sqlForInsertIntoTable:(NSString *)tableName isReplace:(BOOL)isReplace;

- (NSString *)sqlForUpdateTable:(NSString *)tableName whereSql:(NSString *)whereSql;

+ (NSString *)sqlForSelectTable:(NSString *)tableName whereSql:(NSString *)whereSql orderbySql:(NSString *)orderbySql limitSql:(NSString *)limitSql;

+ (NSString *)sqlForDeleteTable:(NSString *)tableName whereSql:(NSString *)whereSql;

+ (NSString *)sqlForDropTable:(NSString *)tableName;

+ (id)modelForKeyValue:(NSDictionary *)keyValues;

+ (NSString *)propertyNameWithDBKey:(NSString *)dbKey;

+ (id)propertyName:(NSString *)propertyName valueCheckIsDictionaryOrArray:(id)value;

+ (NSString *)t_tableName;

@end

@protocol TDBModelDelegate <NSObject>

@optional

+ (NSString *)t_dbModelTableName;

+ (NSArray *)t_dbModelPrimaryKeyPropertyNames;
+ (NSArray *)t_dbModelAutoIncrementPropertyNames;

+ (NSDictionary *)t_dbModelObjectClassInDictionary;

@end
