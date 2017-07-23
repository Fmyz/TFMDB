//
//  TFMDBHelper+SQLCipher.h
//  TCodeStudy
//
//  Created by Liu on 2017/7/23.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper.h"

@interface TFMDBHelper (SQLCipher)

/** encrypt sqlite database (same file) */
+ (BOOL)encryptDatabase:(NSString *)path password:(NSString *)password;

/** decrypt sqlite database (same file) */
+ (BOOL)unEncryptDatabase:(NSString *)path password:(NSString *)password;

/** encrypt sqlite database to new file */
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath password:(NSString *)password;

/** decrypt sqlite database to new file */
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath password:(NSString *)password;

/** change secretKey for sqlite database */
+ (BOOL)changeKey:(NSString *)dbPath originPassword:(NSString *)originPassword newPassword:(NSString *)newPassword;

@end
