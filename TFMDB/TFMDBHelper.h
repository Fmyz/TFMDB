//
//  TFMDBHelper.h
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;
@interface TFMDBHelper : NSObject

//user database version >= 0
@property (nonatomic, assign) uint32_t userDBVersion;

- (BOOL)openDB:(NSString *)path password:(NSString *)password;

- (void)closeDB;

/*FMDB Handler*/
/*create, insert, replace, update, delete, drop, alter*/
- (BOOL)executeUpdate:(NSString *)sql;
- (BOOL)executeUpdateWithFormat:(NSString*)format, ... NS_REQUIRES_NIL_TERMINATION;
///在一个字符串中执行多语句
- (BOOL)executeStatements:(NSString *)sql;
///插入较多的数据
- (BOOL)executeTransaction:(NSArray *)sqls;

- (void)executeQuery:(NSString *)sql complete:(void(^)(FMResultSet *rs))complete;

@end

@interface TFMDBHelper (Specifics)

///查询表列数
- (int)executeSelectRowCountFromTable:(NSString *)tableName;

///给表增加一列 columnType:INTEGER,FLOAT,TEXT,...
- (BOOL)executeAddColumn:(NSString *)columnName columnType:(NSString *)columnType tableName:(NSString *)tableName;

///更换表名
- (BOOL)executeRename:(NSString *)oldName newName:(NSString *)newName;

///删除表
- (BOOL)executeDropTable:(NSString *)tableName;

///

@end

@interface TFMDBHelper (Additions)

- (NSString *)getTableSchema:(NSString*)tableName;

///判断表有没有这列
- (BOOL)existsColumn:(NSString *)columnName tableName:(NSString *)tableName;
///判断有没有这张表
- (BOOL)existsTable:(NSString*)tableName;

@end


