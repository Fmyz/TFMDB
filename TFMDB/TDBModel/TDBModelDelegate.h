//
//  TDBModelDelegate.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/8/7.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDBModelDelegate <NSObject>

@optional
///表名
+ (NSString *)t_dbModelTableName;

///主键 (Create table will apped PRIMARY KEY)
+ (NSArray *)t_dbModelPrimaryKeyPropertyNames;

///自增 (Create table will apped AUTOINCREMENT)
+ (NSArray *)t_dbModelAutoIncrementPropertyNames;

///非空 (Create table will apped NOT NULL)
+ (NSArray *)t_dbModelNotNullPropertyNames;

///默认值 (Create table will apped DEFAULT value，TEXT need "'%@'") 
+ (NSDictionary<NSString *, NSString *> *)t_dbModelDefaultPropertyNamesAndValues;

///唯一值 (Create table will apped UNIQUE)
+ (NSArray *)t_dbModelUniquePropertyNames;

///检查值 (Create table will apped CHECK(Condition))
+ (NSDictionary<NSString *, NSString *> *)t_dbModelCheckPropertyNamesAndConditions;

/**
 *  字典中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)t_dbModelObjectClassInDictionary;

///相当于mj_objectClassInArray，如果实现mj_objectClassInArray方法，可以不实现该方法
+ (NSDictionary *)t_dbModelObjectClassInArray;

///相当于mj_allowedPropertyNames，如果实现mj_allowedPropertyNames方法，可以不实现该方法
+ (NSArray *)t_dbModelAllowedPropertyNames;

///相当于mj_ignoredPropertyNames，如果实现mj_ignoredPropertyNames方法，可以不实现该方法
+ (NSArray *)t_dbModelIgnoredPropertyNames;

@end
