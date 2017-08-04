//
//  TFMDBHelper+TDBModelExecute.m
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper+TDBModelExecute.h"
#import "NSObject+TDBModel.h"
#import "FMResultSet.h"

@implementation TFMDBHelper (TDBModelExecute)

- (BOOL)executeCreateTable:(NSString *)tableName modelClass:(Class)modelClass
{
    NSString *sql = [modelClass sqlForCreateTable:tableName];
    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (BOOL)executeInsertIntoTable:(NSString *)tableName model:(id)model
{
    NSString *sql = [model sqlForInsertIntoTable:tableName isReplace:NO];

    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (BOOL)executeReplaceIntoTable:(NSString *)tableName model:(id)model
{
    NSString *sql = [model sqlForInsertIntoTable:tableName isReplace:YES];
    
    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (BOOL)executeUpdateTable:(NSString *)tableName model:(id)model whereSql:(NSString *)whereSql
{
    NSString *sql = [model sqlForUpdateTable:tableName whereSql:whereSql];

    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (NSArray *)executeSelectTable:(NSString *)tableName modelClass:(Class)modelClass whereSql:(NSString *)whereSql orderbySql:(NSString *)orderbySql limitSql:(NSString *)limitSql
{

    NSString *sql = [modelClass sqlForSelectTable:tableName whereSql:whereSql orderbySql:orderbySql limitSql:limitSql];

    __block NSMutableArray *models = [NSMutableArray array];
    
    [self executeQuery:sql complete:^(FMResultSet *rs) {

        NSDictionary *map = [rs.columnNameToIndexMap copy];
        
        NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
        for (id key in map) {
            int index = [[map objectForKey:key] intValue];
            id value = [rs objectForColumnIndex:index];
            if (value && ![value isKindOfClass:[NSNull class]]) {
                NSString *propertyName = [modelClass propertyNameWithDBKey:key];
                
                value = [modelClass propertyName:propertyName valueCheckIsDictionaryOrArray:value];
                
                if (propertyName && ![propertyName isKindOfClass:[NSNull class]]) {
                    [keyValues setObject:value forKey:propertyName];
                }
            }
        }
        
        if (keyValues.count) {
            id model = [modelClass modelForKeyValue:keyValues];
            [models addObject:model];
        }
    }];
    
#if DEBUG
    [self logSql:sql code:3];
#endif
    return [models copy];
}

- (BOOL)executeDeleteTable:(NSString *)tableName modelClass:(Class)modelClass whereSql:(NSString *)whereSql
{
    NSString *sql = [modelClass sqlForDeleteTable:tableName whereSql:whereSql];
    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (BOOL)executeDropTable:(NSString *)tableName modelClass:(Class)modelClass
{
    NSString *sql = [modelClass sqlForDropTable:tableName];
    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql code:suc];
#endif
    return suc;
}

- (void)logSql:(NSString *)sql code:(int)code
{
    NSLog(@"TModelExecute sql: %@ suc:%d", sql, code);
}

@end
