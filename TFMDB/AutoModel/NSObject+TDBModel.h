//
//  NSObject+TDBModel.h
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFMDBHelper;
@interface NSObject (TDBModel)

+ (BOOL)sqlCreateTable:(NSString *)tableName dbHelper:(TFMDBHelper *)dbHelper;

//- (BOOL)sqlInsertTable:(NSString *)tableName;
//- (BOOL)sqlReplaceTable:(NSString *)tableName;
//
//- (BOOL)sqlUpdateTable:(NSString *)tableName;
//
//- (BOOL)sqlDeleteTable:(NSString *)tableName;
//
//- (BOOL)sqlDropTable:(NSString *)tableName;

@end

@protocol TDBModelDelegate <NSObject>

@optional
+ (NSArray *)sql_primaryKeyPropertyNames;
+ (NSArray *)sql_autoIncrementPropertyNames;

@end
