//
//  TFMDBHelper+TDBModelExecute.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper.h"

@interface TFMDBHelper (TDBModelExecute)

- (BOOL)executeCreateTable:(NSString *)tableName modelClass:(Class)modelClass;

- (BOOL)executeInsertIntoTable:(NSString *)tableName model:(id)model;

- (BOOL)executeReplaceIntoTable:(NSString *)tableName model:(id)model;

- (BOOL)executeUpdateTable:(NSString *)tableName model:(id)model whereSql:(NSString *)whereSql;

- (NSArray *)executeSelectTable:(NSString *)tableName modelClass:(Class)modelClass whereSql:(NSString *)whereSql orderbySql:(NSString *)orderbySql limitSql:(NSString *)limitSql;

- (BOOL)executeDeleteTable:(NSString *)tableName modelClass:(Class)modelClass whereSql:(NSString *)whereSql;

- (BOOL)executeDropTable:(NSString *)tableName modelClass:(Class)modelClass;

@end
