//
//  Classes.h
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Classes : NSObject

@property (assign, nonatomic) NSInteger cid;    //班级id
@property (copy, nonatomic) NSArray *teacher;   //老师
@property (assign, nonatomic) NSInteger number;   //人数

@end
