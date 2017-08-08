//
//  TSQLCipherFMDatabase.m
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TSQLCipherFMDatabase.h"
#import "sqlite3.h"

@interface TSQLCipherFMDatabase ()

@property (copy, nonatomic) NSString *password;

@end


@implementation TSQLCipherFMDatabase

+ (instancetype)databaseWithPath:(NSString*)path password:(NSString *)password
{
    return [[[self class] alloc] initWithPath:path password:password];
}

- (instancetype)initWithPath:(NSString*)path password:(NSString *)password
{
    if (self = [self initWithPath:path]) {
        self.password = password;
    }
    return self;
}

#pragma mark - Override Method
- (BOOL)open
{
    BOOL res = [super open];
    if (res && _password) {
        //数据库open后设置加密key
        [self setKey:_password];
    }
    return res;
}

#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName
{
    BOOL res = [super openWithFlags:flags vfs:vfsName];
    if (res && _password) {
        //数据库open后设置加密key
        [self setKey:_password];
    }
    return res;
}

#endif

@end
