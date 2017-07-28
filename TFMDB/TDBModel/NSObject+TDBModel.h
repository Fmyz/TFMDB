//
//  NSObject+TDBModel.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TDBModel)

+ (NSString *)sqlForCreateTable:(NSString *)tableName;


@end

@protocol TDBModelDelegate <NSObject>

@optional

+ (NSString *)t_dbModelTableName;

+ (NSArray *)t_dbModePrimaryKeyPropertyNames;
+ (NSArray *)t_dbModeAutoIncrementPropertyNames;

@end
