# TFMDB
FMDB SQLCipher, DBModel auto sql

pod 'TFMDB'

/*Cipher*/
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
NSString *directory = [paths firstObject];
NSString *dbPath = [directory stringByAppendingPathComponent:@"test.db"];

NSString *password = @"YourPassword";
self.password = password;

//加密
BOOL suc = [TestDBHelper encryptDatabase:dbPath password:password];
//解密
BOOL suc = [TestDBHelper unEncryptDatabase:dbPath password:self.password];
//打开数据库
BOOL suc = [helper openDB:dbPath password:self.password];

/*TDBModel*/
//创建表
BOOL suc = [_helper executeCreateTable:nil modelClass:[Student class]];
//插入
BOOL suc = [_helper executeInsertIntoTable:nil model:student];
//替换插入
BOOL suc = [_helper executeReplaceIntoTable:nil model:student];
//更新
BOOL suc = [_helper executeUpdateTable:nil model:student whereSql:nil];
//查询
NSArray<Student *> *students = [_helper executeSelectTable:nil modelClass:[Student class] whereSql:@"cid = 1701" orderbySql:@"sId DESC" limitSql:@"2"];
//删除表内容
BOOL suc = [_helper executeDeleteTable:nil modelClass:[Student class] whereSql:nil];
//删除表
BOOL suc = [_helper executeDropTable:nil modelClass:[Student class]];
