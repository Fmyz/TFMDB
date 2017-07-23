//
//  TSQLCipherFMDatabase.h
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface TSQLCipherFMDatabase : FMDatabase

+ (instancetype)databaseWithPath:(NSString*)path password:(NSString *)password;

- (instancetype)initWithPath:(NSString*)path password:(NSString *)password;

@end
