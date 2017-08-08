//
//  NSObject+TDBModel.m
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "NSObject+TDBModel.h"
#import "TDBModelUtils.h"

@implementation NSObject (TDBModel)

+ (NSString *)sqlForCreateTable:(NSString *)tableName
{
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return nil;
    }
    
    NSArray<NSString *> *ivarNames = [self getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return nil;
    }
    NSInteger count = MIN(propertys.count, ivarNames.count);

    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];

    NSArray *primaryKeyPropertyNames = [self t_primaryKeyPropertyNames];
    NSArray *autoIncrementPropertyNames = [self t_autoIncrementPropertyNames];
    NSArray *notNullPropertyNames = [self t_notNullPropertyNames];
    NSDictionary *defaultPropertyNamesAndValues = [self t_defaultPropertyNamesAndValues];
    NSArray *uniquePropertyNames = [self t_uniquePropertyNames];
    NSDictionary *checkPropertyNamesAndConditions = [self t_checkPropertyNamesAndConditions];
    
    NSMutableArray<NSString *> *columns = [NSMutableArray array];
    
    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        
        NSString *sqlType = [self sqlTypeWithProperty:property];
        if (!sqlType) {
            continue;
        }
        
        NSString *name = property.name;
        NSString *column = [name stringByAppendingString:@" "];
        column = [column stringByAppendingString:sqlType];
        
        if ([primaryKeyPropertyNames containsObject:name]) {
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingString:tSql_Attribute_PrimaryKey];
        }
        
        if ([autoIncrementPropertyNames containsObject:name]) {
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingString:tSql_Attribute_AutoIncrement];
        }
        
        if ([notNullPropertyNames containsObject:name]) {
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingString:tSql_Attribute_NotNull];
        }
        
        if ([defaultPropertyNamesAndValues.allKeys containsObject:name]) {
            id dValue = [defaultPropertyNamesAndValues objectForKey:name];
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingFormat:@"%@ %@", tSql_Attribute_Default, dValue];
        }
        
        if ([uniquePropertyNames containsObject:name]) {
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingString:tSql_Attribute_Unique];
        }
        
        if ([checkPropertyNamesAndConditions.allKeys containsObject:name]) {
            id condition = [checkPropertyNamesAndConditions objectForKey:name];
            column = [column stringByAppendingString:@" "];
            column = [column stringByAppendingFormat:@"%@(%@)", tSql_Attribute_Check, condition];
        }
        
        [columns addObject:column];
    }
    
    if (columns.count) {
        NSString *sqlColumn = [columns componentsJoinedByString:@", "];
        sql = [sql stringByAppendingString:sqlColumn];
    }
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *)sqlForInsertIntoTable:(NSString *)tableName isReplace:(BOOL)isReplace
{
    Class modelClass = [self class];
    if (!tableName || !tableName.length) {
        tableName = [modelClass t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSArray<MJProperty *> *propertys = [modelClass getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return nil;
    }
    
    NSArray<NSString *> *ivarNames = [modelClass getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return nil;
    }
    NSInteger count = MIN(propertys.count, ivarNames.count);
    
    NSString *sql = isReplace? @"REPLACE" : @"INSERT";
    sql = [NSString stringWithFormat:@"%@ INTO %@ (", sql, tableName];
    
    NSDictionary *keyValues = [self mj_keyValues];
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];

    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        
        NSString *sqlType = [modelClass sqlTypeWithProperty:property];
        if (!sqlType) {
            continue;
        }
        
        NSString *key = property.name;
        id value = [keyValues objectForKey:key];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            [keys addObject:key];
            
            if ([sqlType isEqualToString:tSql_Type_Text]) {
                value = [modelClass jsonWithValue:value];
                value = [value mj_JSONString];
                value = [NSString stringWithFormat:@"'%@'", (NSString *)value];
            }
            [values addObject:value];
        }
    }
    
    if (keys.count) {
        NSString *keysStr = [keys componentsJoinedByString:@", "];
        sql = [sql stringByAppendingString:keysStr];
    }
    
    sql = [sql stringByAppendingString:@") VALUES("];
    
    if (values.count) {
        NSString *valuesStr = [values componentsJoinedByString:@", "];
        sql = [sql stringByAppendingString:valuesStr];
    }
    
    sql = [sql stringByAppendingString:@")"];
    
    return sql;
}

- (NSString *)sqlForUpdateTable:(NSString *)tableName whereSql:(NSString *)whereSql
{
    Class modelClass = [self class];
    if (!tableName || !tableName.length) {
        tableName = [modelClass t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSArray<MJProperty *> *propertys = [modelClass getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return nil;
    }
    
    NSArray<NSString *> *ivarNames = [modelClass getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return nil;
    }
    NSInteger count = MIN(propertys.count, ivarNames.count);
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET ", tableName];
    
    NSDictionary *keyValues = [self mj_keyValues];
    NSMutableArray *keyValuesArr = [NSMutableArray array];
    
    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        
        NSString *sqlType = [modelClass sqlTypeWithProperty:property];
        if (!sqlType) {
            continue;
        }
        
        NSString *key = property.name;
        id value = [keyValues objectForKey:key];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            if ([sqlType isEqualToString:tSql_Type_Text]) {
                value = [modelClass jsonWithValue:value];
                value = [value mj_JSONString];
                value = [NSString stringWithFormat:@"'%@'", (NSString *)value];
            }
            [keyValuesArr addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
        }
    }
    
    if (keyValuesArr.count) {
        NSString *keyValuesStr = [keyValuesArr componentsJoinedByString:@", "];
        sql = [sql stringByAppendingString:keyValuesStr];
    }
    
    sql = [modelClass sql:sql byAppendingCondition:whereSql rangeOfString:tSql_Condition_Where];
    
    return sql;
}

+ (NSString *)sqlForSelectTable:(NSString *)tableName whereSql:(NSString *)whereSql orderbySql:(NSString *)orderbySql limitSql:(NSString *)limitSql
{
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return nil;
    }
    
    NSArray<NSString *> *ivarNames = [self getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return nil;
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    
    sql = [self sql:sql byAppendingCondition:whereSql rangeOfString:tSql_Condition_Where];
    sql = [self sql:sql byAppendingCondition:orderbySql rangeOfString:tSql_Condition_OrderBy];
    sql = [self sql:sql byAppendingCondition:limitSql rangeOfString:tSql_Condition_Limit];
    
    return sql;
}

+ (NSString *)sqlForDeleteTable:(NSString *)tableName whereSql:(NSString *)whereSql
{
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    sql = [self sql:sql byAppendingCondition:whereSql rangeOfString:tSql_Condition_Where];
    
    return sql;
}

+ (NSString *)sqlForDropTable:(NSString *)tableName
{
    if (!tableName || !tableName.length) {
        tableName = [self t_tableName];
    }
    
    if (!tableName || !tableName.length) {
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    
    return sql;
}

+ (NSArray *)getClassMJPropertys
{
    __block NSMutableArray<MJProperty *> *propertys = [NSMutableArray array];
    
    NSArray *allowedPropertyNames = [self t_allowedPropertyNames];
    NSArray *ignoredPropertyNames = [self t_ignoredPropertyNames];
    [self mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
        if ([ignoredPropertyNames containsObject:property.name]) return;
        
        [propertys addObject:property];
    }];
    
    return [propertys copy];
}

+ (NSArray<NSString *> *)getClassIvarNames
{
    NSMutableArray<NSString *> *ivarNames = [NSMutableArray array];
    
    NSArray *allowedPropertyNames = [self t_allowedPropertyNames];
    NSArray *ignoredPropertyNames = [self t_ignoredPropertyNames];
    
    unsigned int count;
    Ivar *ivar = class_copyIvarList(self, &count);
    for (int i=0; i<count; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *ivarName = [NSString stringWithUTF8String:name];
        NSString *propertyName = [self replaceFirstUnderline:ivarName];
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:propertyName]) continue;
        if ([ignoredPropertyNames containsObject:propertyName]) continue;
        
        [ivarNames addObject:propertyName];
    }
    free(ivar);
    
    return [ivarNames copy];
}

+ (NSString *)sqlTypeWithProperty:(MJProperty *)property
{
    MJPropertyType *type = property.type;
    NSString *sqlType = nil;
    if (type.isBoolType) {
        sqlType = tSql_Type_Blob;
    } else if (type.isNumberType) {
        NSString *code = type.code;
        if ([code isEqualToString:@"f"]) {
            sqlType = tSql_Type_Float;
        } else if ([code isEqualToString:@"d"]) {
            sqlType = tSql_Type_Double;
        } else if ([code isEqualToString:@"i"] || [code isEqualToString:@"s"]) {
            sqlType = tSql_Type_Int;
        } else if ([code isEqualToString:@"l"] || [code isEqualToString:@"q"] || [code isEqualToString:@"I"] || [code isEqualToString:@"Q"]) {
            sqlType = tSql_Type_Integer;
        }
    } else if (type.isFromFoundation || type.isIdType) {
        sqlType = tSql_Type_Text;
    }
    return sqlType;
}

+ (NSString *)sql:(NSString *)sql byAppendingCondition:(NSString *)condition rangeOfString:(NSString *)rangeOfString
{
    if (!condition) {
        return sql;
    }
    
    if ([condition rangeOfString:rangeOfString options:NSCaseInsensitiveSearch].location == NSNotFound) {
        sql = [sql stringByAppendingFormat:@" %@ ", rangeOfString];
    }
    
    sql = [sql stringByAppendingString:condition];
    
    return sql;
}

///字典转模型
+ (id)modelForKeyValue:(NSDictionary *)keyValues
{
    id model = [self mj_objectWithKeyValues:keyValues];
    return model;
}

///根据表列名(全小写)转换属性名
+ (NSString *)propertyNameWithDBKey:(NSString *)dbKey
{
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return dbKey;
    }
    
    NSArray<NSString *> *ivarNames = [self getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return dbKey;
    }
    NSInteger count = MIN(propertys.count, ivarNames.count);
    
    NSString *propertyName = dbKey;
    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        
        NSString *lowerPropertyName = [property.name lowercaseString];
        if (![lowerPropertyName isEqualToString:dbKey]) {
            continue;
        }
        propertyName = property.name;
        break;
        
    }
    return propertyName;
}

///转换表数据的值
+ (id)propertyName:(NSString *)propertyName valueCheckIsDictionaryOrArray:(id)value
{
    NSDictionary *objectClassInDictionary = [self t_objectClassInDictionary];
    NSDictionary *objectClassInArray = [self t_objectClassInArray];
    
    BOOL hasObjectClassInDictionary = (objectClassInDictionary && objectClassInDictionary.count);
    BOOL hasObjectClassInArray = (objectClassInArray && objectClassInArray.count);
    
    if (!hasObjectClassInDictionary && !hasObjectClassInArray) {
        return value;
    }
    
    NSArray<MJProperty *> *propertys = [self getClassMJPropertys];
    if (!propertys && !propertys.count) {
        return value;
    }
    
    NSArray<NSString *> *ivarNames = [self getClassIvarNames];
    if (!ivarNames && !ivarNames.count) {
        return value;
    }
    NSInteger count = MIN(propertys.count, ivarNames.count);
    
    NSArray *objectClassInDictionaryKeys = nil;
    if (hasObjectClassInDictionary) {
        objectClassInDictionaryKeys = objectClassInDictionary.allKeys;
    }
    NSArray *objectClassInArrayKeys = nil;
    if (hasObjectClassInArray) {
        objectClassInArrayKeys = objectClassInArray.allKeys;
    }
    
    id jsonObject = value;
    for (NSInteger index = 0; index < count; index++) {
        MJProperty *property = [propertys objectAtIndex:index];
        if (![ivarNames containsObject:property.name]) {
            continue;
        }
        if (![property.name isEqualToString:propertyName]) {
            continue;
        }
        
        if (hasObjectClassInDictionary && [objectClassInDictionaryKeys containsObject:propertyName]) {
            jsonObject = [value mj_JSONObject];
            Class modelClass = [self t_classFromDictionary:objectClassInDictionary key:propertyName];
            if (!modelClass) {
                break;
            }
            
            id modelObject = [modelClass modelObjectForJsonDictionaryObejct:jsonObject];
            jsonObject = modelObject;
            
        } else if (hasObjectClassInArray && [objectClassInArrayKeys containsObject:propertyName]) {
            jsonObject = [value mj_JSONObject];
            Class modelClass = [self t_classFromDictionary:objectClassInArray key:propertyName];
            if (!modelClass) {
                break;
            }
            id modelObject = [modelClass modelObjectForJsonArrayObejct:jsonObject];
            jsonObject = modelObject;
        }
        break;
    }
    
    return jsonObject;
}

+ (NSString *)jsonWithValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mValue = [NSMutableDictionary dictionaryWithDictionary:value];
        NSArray *subKeys = [mValue allKeys];
        for (id subKey in subKeys) {
            id subValue = [value objectForKey:subKey];
            
            id keyValues = [subValue mj_keyValues];
            if ([keyValues isKindOfClass:[NSDictionary class]]) {
                subValue = [self jsonWithValue:keyValues];
            }
            subValue = [self jsonWithValue:subValue];
            [mValue setObject:subValue forKey:subKey];
        }
        
        if (mValue) {
            value = [mValue copy];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *mValue = [NSMutableArray arrayWithArray:value];
        for (id object in value) {
            id newObject = object;
            id keyValues = [object mj_keyValues];
            if ([keyValues isKindOfClass:[NSDictionary class]]) {
                newObject = [self jsonWithValue:keyValues];
            }
            id jsonObject = [self jsonWithValue:newObject];
            NSInteger index = [value indexOfObject:object];
            [mValue replaceObjectAtIndex:index withObject:jsonObject];
        }
        if (mValue) {
            value = [mValue copy];
        }
    } else {
        if ([value isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber *)value).stringValue;
        }
        value = [value mj_JSONString];
    }
    return value;
}

+ (id)modelObjectForJsonDictionaryObejct:(id)jsonObject
{
    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        return jsonObject;
    }
    
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithDictionary:jsonObject];
    for (id jsonKey in ((NSDictionary *)jsonObject).allKeys) {
        id jsonValue = [jsonObject objectForKey:jsonKey];
        
        if (!jsonValue || ![jsonValue isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSMutableDictionary *subModelDict = [NSMutableDictionary dictionary];
        for (id subKey in ((NSDictionary *)jsonValue).allKeys) {
            id subValue = [jsonValue objectForKey:subKey];
            subValue = [self propertyName:subKey valueCheckIsDictionaryOrArray:subValue];
            if (subValue) {
                [subModelDict setObject:subValue forKey:subKey];
            }
        }
        
        jsonValue = [subModelDict copy];
        jsonValue = [self mj_objectWithKeyValues:jsonValue];
        [modelDict setObject:jsonValue forKey:jsonKey];
    }
    return [modelDict copy];
}

+ (id)modelObjectForJsonArrayObejct:(id)jsonObject
{
    if (![jsonObject isKindOfClass:[NSArray class]]) {
        return jsonObject;
    }
    NSMutableArray *modelArray = [NSMutableArray array];
    
    for (id object in (NSArray *)jsonObject) {
        id jsonValue = object;
        if (!jsonValue || ![jsonValue isKindOfClass:[NSDictionary class]]) {
            [modelArray addObject:jsonValue];
            continue;
        }
        
        NSMutableDictionary *subModelDict = [NSMutableDictionary dictionary];
        for (id subKey in ((NSDictionary *)jsonValue).allKeys) {
            id subValue = [jsonValue objectForKey:subKey];
            subValue = [self propertyName:subKey valueCheckIsDictionaryOrArray:subValue];
            if (subValue) {
                [subModelDict setObject:subValue forKey:subKey];
            }
        }
        jsonValue = [subModelDict copy];
        jsonValue = [self mj_objectWithKeyValues:jsonValue];
        if (jsonValue) {
            [modelArray addObject:jsonValue];
        }
    }
    
    return [modelArray copy];
}

+ (Class)t_classFromDictionary:(NSDictionary *)dictionary key:(NSString *)key
{
    id objectClass = [dictionary objectForKey:key];
    if ([objectClass isKindOfClass:[NSString class]]) {
        objectClass = NSClassFromString(objectClass);
    }
    return objectClass;
}

+ (NSString *)replaceFirstUnderline:(NSString *)ivarName
{
    // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
    // 比如 @property(retain) NSString *abc;则 key == _abc;
    NSString *propertyName = ivarName;
    
    NSString *firstStr = [ivarName substringToIndex:1];
    if ([firstStr isEqualToString:@"_"]) {
        propertyName = [ivarName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    
    return propertyName;
}

+ (NSString *)t_tableName
{
    NSString *t_tableName = nil;
    if ([self respondsToSelector:@selector(t_dbModelTableName)]) {
        t_tableName = [self performSelector:@selector(t_dbModelTableName)];
    }
    return t_tableName;
}

+ (NSArray *)t_primaryKeyPropertyNames
{
    NSArray *t_primaryKeyPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelPrimaryKeyPropertyNames)]) {
        t_primaryKeyPropertyNames = [self performSelector:@selector(t_dbModelPrimaryKeyPropertyNames)];
    }
    return t_primaryKeyPropertyNames;
}

+ (NSArray *)t_autoIncrementPropertyNames
{
    NSArray *t_autoIncrementPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelAutoIncrementPropertyNames)]) {
        t_autoIncrementPropertyNames = [self performSelector:@selector(t_dbModelAutoIncrementPropertyNames)];
    }
    return t_autoIncrementPropertyNames;
}

+ (NSArray *)t_notNullPropertyNames
{
    NSArray *t_notNullPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelNotNullPropertyNames)]) {
        t_notNullPropertyNames = [self performSelector:@selector(t_dbModelNotNullPropertyNames)];
    }
    return t_notNullPropertyNames;
}

+ (NSDictionary *)t_defaultPropertyNamesAndValues
{
    NSDictionary *t_defaultPropertyNamesAndValues = nil;
    
    if ([self respondsToSelector:@selector(t_dbModelDefaultPropertyNamesAndValues)]) {
        t_defaultPropertyNamesAndValues = [self performSelector:@selector(t_dbModelDefaultPropertyNamesAndValues)];
    }
    return t_defaultPropertyNamesAndValues;
}

+ (NSArray *)t_uniquePropertyNames
{
    NSArray *t_uniquePropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelUniquePropertyNames)]) {
        t_uniquePropertyNames = [self performSelector:@selector(t_dbModelUniquePropertyNames)];
    }
    return t_uniquePropertyNames;
}

+ (NSDictionary *)t_checkPropertyNamesAndConditions
{
    NSDictionary *t_checkPropertyNamesAndConditions = nil;
    
    if ([self respondsToSelector:@selector(t_dbModelCheckPropertyNamesAndConditions)]) {
        t_checkPropertyNamesAndConditions = [self performSelector:@selector(t_dbModelCheckPropertyNamesAndConditions)];
    }
    return t_checkPropertyNamesAndConditions;
}

+ (NSDictionary *)t_objectClassInArray
{
    NSDictionary *t_objectClassInArray = nil;
    
    if ([self respondsToSelector:@selector(t_dbModelObjectClassInArray)]) {
        t_objectClassInArray = [self performSelector:@selector(t_dbModelObjectClassInArray)];
    } else if ([self respondsToSelector:@selector(mj_objectClassInArray)]) {
        t_objectClassInArray = [self performSelector:@selector(mj_objectClassInArray)];
    }
    return t_objectClassInArray;
}

+ (NSDictionary *)t_objectClassInDictionary
{
    NSDictionary *t_objectClassInDictionary = nil;
    if ([self respondsToSelector:@selector(t_dbModelObjectClassInDictionary)]) {
        t_objectClassInDictionary = [self performSelector:@selector(t_dbModelObjectClassInDictionary)];
    }
    return t_objectClassInDictionary;
}

+ (NSArray *)t_allowedPropertyNames
{
    NSArray *t_allowedPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelAllowedPropertyNames)]) {
        t_allowedPropertyNames = [self performSelector:@selector(t_dbModelAllowedPropertyNames)];
    } else if ([self respondsToSelector:@selector(mj_allowedPropertyNames)]) {
        t_allowedPropertyNames = [self performSelector:@selector(mj_allowedPropertyNames)];
    }
    return t_allowedPropertyNames;
}

+ (NSArray *)t_ignoredPropertyNames
{
    NSArray *t_ignoredPropertyNames = nil;
    if ([self respondsToSelector:@selector(t_dbModelIgnoredPropertyNames)]) {
        t_ignoredPropertyNames = [self performSelector:@selector(t_dbModelIgnoredPropertyNames)];
    } else if ([self respondsToSelector:@selector(mj_ignoredPropertyNames)]) {
        t_ignoredPropertyNames = [self performSelector:@selector(mj_ignoredPropertyNames)];
    }
    return t_ignoredPropertyNames;
}

@end
