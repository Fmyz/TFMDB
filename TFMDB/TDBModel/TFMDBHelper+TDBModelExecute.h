//
//  TFMDBHelper+TDBModelExecute.h
//  TFMDBDemo
//
//  Created by Fmyz on 2017/7/28.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TFMDBHelper.h"

@interface TFMDBHelper (TDBModelExecute)

- (BOOL)executeCreateTable:(NSString *)tableName modelClass:(Class)modelClass;

@end
