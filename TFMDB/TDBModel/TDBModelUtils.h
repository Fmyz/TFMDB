//
//  TDBModelUtils.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/26.
//  Copyright © 2017年 Tan. All rights reserved.
//

#ifndef TDBModelUtils_h
#define TDBModelUtils_h

static NSString *const tSql_Type_Text = @"TEXT";
static NSString *const tSql_Type_Integer = @"INTEGER";
static NSString *const tSql_Type_Int = @"INT";
static NSString *const tSql_Type_Float = @"FLOAT";
static NSString *const tSql_Type_Double = @"DOUBLE";
static NSString *const tSql_Type_Blob = @"BLOB";

static NSString *const tSql_Attribute_NotNull = @"NOT NULL";
static NSString *const tSql_Attribute_PrimaryKey = @"PRIMARY KEY";
static NSString *const tSql_Attribute_Default = @"DEFAULT";
static NSString *const tSql_Attribute_AutoIncrement = @"AUTOINCREMENT";
static NSString *const tSql_Attribute_Unique = @"UNIQUE";

static NSString *const tSql_Condition_Where = @"WHERE";
static NSString *const tSql_Condition_OrderBy = @"ORDER BY";
static NSString *const tSql_Condition_Limit = @"LIMIT";

#endif /* TDBModelUtils_h */
