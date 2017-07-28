//
//  TFMDBHelper+TDBModelExecute.m
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper+TDBModelExecute.h"
#import "NSObject+TDBModel.h"

@implementation TFMDBHelper (TDBModelExecute)

- (BOOL)executeCreateTable:(NSString *)tableName modelClass:(Class)modelClass
{
    NSString *sql = [modelClass sqlForCreateTable:tableName];
    BOOL suc = [self executeUpdate:sql];
#if DEBUG
    [self logSql:sql suc:suc];
#endif
    return suc;
}

- (void)logSql:(NSString *)sql suc:(BOOL)suc
{
    NSLog(@"TModelExecute sql: %@ suc:%d", sql, suc);
}

@end
