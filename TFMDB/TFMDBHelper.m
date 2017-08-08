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

- (BOOL)executeTransaction:(NSArray *)sqls progress:(void (^)(NSInteger, NSInteger, NSString *))progress
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    __block BOOL success;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in sqls) {
            success = [db executeUpdate:sql];
            
            NSInteger index = [sqls indexOfObject:sql];
            NSInteger count = sqls.count;
            
            NSString *errorMsg = success?nil:[NSString stringWithFormat:@"error at %ld/%ld, sql:%@", (long)index, (long)count, sql];
            
            if (progress) {
                progress(index, count, errorMsg);
            }
            
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
        while ([rs next]) {
            // 每条记录的检索值
            if (complete) {
                __weak typeof(rs) weakRS = rs;
                complete(weakRS);
            }
        }
        [rs close];
    }];
    
}

@end

@implementation TFMDBHelper (Specifics)

- (int)executeSelectRowCountFromTable:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return 0;
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(1) FROM %@", tableName];
    
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
    
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, columnName, columnType];
    BOOL suc =  [self executeUpdate:sql];
    
    return suc;
}

- (BOOL)executeRename:(NSString *)oldName newName:(NSString *)newName
{
    if (![self isOpenDB]) {
        return NO;
    }
    BOOL exists = [self existsTable:newName];
    if (exists) {
        return YES;
    }
    
    NSString *sql = [NSString stringWithFormat:@"alter table %@ rename to %@", oldName, newName];
    BOOL suc =  [self executeUpdate:sql];
    
    return suc;
}

- (BOOL)executeCreateIndex:(NSString *)indexName tableName:(NSString *)tableName columnNames:(NSArray *)columnNames unique:(BOOL)unique
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    NSString *sql = @"CREATE";
    
    NSString *uniqueStr = unique?@"UNIQUE":nil;
    if (uniqueStr) {
        sql = [sql stringByAppendingFormat:@" %@", uniqueStr];
    }
    
    sql = [sql stringByAppendingFormat:@" INDEX %@ ON %@", indexName, tableName];
    
    NSString *columnStr = nil;
    if (columnNames.count) {
        columnStr = [columnNames componentsJoinedByString:@","];
    }
    
    if (columnStr && columnStr.length) {
        sql = [sql stringByAppendingFormat:@" (%@)", columnStr];
    }
    
    BOOL suc =  [self executeUpdate:sql];
    return suc;
}

- (BOOL)executeDropIndex:(NSString *)indexName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DROP INDEX %@", indexName];
    BOOL suc =  [self executeUpdate:sql];
    
    return suc;

}

- (BOOL)executeDropTable:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    BOOL suc =  [self executeUpdate:sql];

    return suc;
}

@end

@implementation TFMDBHelper (Additions)

- (NSString *)getTableSchema:(NSString *)tableName
{
    if (![self isOpenDB]) {
        return nil;
    }
    
    if (![self existsTable:tableName]) {
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];
    __block NSString *schema = sql;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db getTableSchema:tableName];
        
        NSMutableArray *attrStrs = [NSMutableArray array];
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"name"];
            NSString *type = [rs stringForColumn:@"type"];
            BOOL pk = [[rs objectForColumn:@"pk"] boolValue];
            BOOL notnull = [[rs objectForColumn:@"notnull"] boolValue];
            id dflt_value = [rs objectForColumn:@"dflt_value"];
            
            NSMutableArray *attrs = [NSMutableArray arrayWithObjects:name, type, nil];
            if (pk) {
                NSString *pkStr = @"PRIMARY KEY";
                [attrs addObject:pkStr];
            }
            if (notnull) {
                NSString *notnullStr = @"NOT NULL";
                [attrs addObject:notnullStr];
            }
            if (dflt_value && ![dflt_value isKindOfClass:[NSNull class]]) {
                if ([dflt_value isKindOfClass:[NSNumber class]]) {
                    dflt_value = ((NSNumber *)dflt_value).stringValue;
                }
                NSString *defaultStr = [NSString stringWithFormat:@"DEFAULT %@", dflt_value];
                [attrs addObject:defaultStr];
            }
            
            NSString *attrStr = [attrs componentsJoinedByString:@" "];
            [attrStrs addObject:attrStr];
        }
        [rs close];
        
        if (attrStrs.count) {
            NSString *columnStr = [attrStrs componentsJoinedByString:@", "];
            schema = [schema stringByAppendingString:columnStr];
            schema = [schema stringByAppendingString:@")"];
        }
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

