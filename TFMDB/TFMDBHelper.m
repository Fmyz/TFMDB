//
//  TFMDBHelper.m
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper.h"
#import "TSQLCipherFMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

@interface TFMDBHelper ()

@property (strong, nonatomic) TSQLCipherFMDatabaseQueue *dbQueue;
@property (copy, nonatomic) NSString *dbPath;
@property (copy, nonatomic) NSString *password;

@end

@implementation TFMDBHelper

@synthesize userDBVersion = _userDBVersion;

- (BOOL)openDB:(NSString *)path password:(NSString *)password
{
    self.dbPath = path;
    [self closeDB];
    
    if (!_dbQueue) {
        _dbQueue = [TSQLCipherFMDatabaseQueue databaseQueueWithPath:path password:password];
    }
    
    if (_dbQueue == 0x00) {
        return NO;
    }
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db setDateFormat:[FMDatabase storeableDateFormat:@"yyyy-MM-dd HH:mm:ss"]];//yyyy-MM-dd HH:mm:ss.SSS
    }];
    
    return YES;
}

- (void)closeDB
{
    if (_dbQueue) {
        [_dbQueue close];
        _dbQueue = nil;
    }
}

- (BOOL)isOpenDB
{
    if (_dbQueue) {
        if (_dbQueue == 0x00) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (uint32_t)userDBVersion
{
    if (![self isOpenDB]) {
        return 0;
    }
    __block uint32_t userDBVersion;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        userDBVersion = db.userVersion;
    }];
    return userDBVersion;
}

- (void)setUserDBVersion:(uint32_t)userDBVersion
{
    if (_userDBVersion == userDBVersion) {
        return;
    }
    if (![self isOpenDB]) {
        return;
    }
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db setUserVersion:userDBVersion];
    }];
}

- (BOOL)executeUpdate:(NSString *)sql
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql];
    }];
    
    return success;
}

- (BOOL)executeUpdateWithFormat:(NSString *)format, ...
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success = NO;
    va_list args;
    va_start(args, format);
    id eachObject;
    NSMutableArray* arr = [NSMutableArray array];
    while ((eachObject = va_arg(args, id))) {
        [arr addObject:eachObject];
    }
    va_end(args);
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:format withArgumentsInArray:arr];        
    }];
    
    return success;
}

- (BOOL)executeStatements:(NSString *)sql
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeStatements:sql];
    }];
    
    return success;
}

- (BOOL)executeTransaction:(NSArray *)sqls
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in sqls) {
           success = [db executeUpdate:sql];
            
            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];
    
    return success;
}

- (void)executeQuery:(NSString *)sql complete:(void (^)(FMResultSet *))complete
{
    if (![self isOpenDB]) {
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        if (complete) {
            __weak typeof(rs) weakRS = rs;
            complete(weakRS);
        }
        
        [rs close];
    }];
    
}

@end

@implementation TFMDBHelper (Specifics)

- (int)executeSelectRowCount:(NSString *)sql
{
    if (![self isOpenDB]) {
        return 0;
    }
    
    __block int rowCount = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            rowCount = [rs intForColumnIndex:0];
        }
        
        [rs close];
    }];
    
    return rowCount;
}

- (BOOL)executeAddColumn:(NSString *)columnName columnType:(NSString *)columnType tableName:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    BOOL exists = [self existsColumn:columnName tableName:tableName]; //判断存不存在
    if (exists) {
        return YES;
    }
    
    NSString *alterSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", tableName, columnName, columnType];
    BOOL suc =  [self executeUpdate:alterSql];
    
    return suc;
}

- (BOOL)executeDropTable:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    NSString *dropTableSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    BOOL suc =  [self executeUpdate:dropTableSql];

    return suc;
}

@end

@implementation TFMDBHelper (Additions)

- (NSString *)getTableSchema:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return nil;
    }
    
    __block NSString *schema = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db getTableSchema:tableName];
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"name"];
            schema = [NSString stringWithFormat:@"%@", name];
        }
        [rs close];
    }];
    return schema;
}

- (BOOL)existsColumn:(NSString *)columnName tableName:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db columnExists:columnName inTableWithName:tableName];
    }];
    return success;
}

- (BOOL)existsTable:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db tableExists:tableName];
    }];
    return success;
}

@end

