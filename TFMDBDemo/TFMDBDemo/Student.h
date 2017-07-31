//
//  Student.h
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SInfo;
@interface Student : NSObject

@property (assign, nonatomic) NSInteger sId;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary<NSString *, SInfo *> *SInfoDic;
@property (assign, nonatomic) NSInteger cid;

@property (copy, nonatomic) NSString *ignoreStr; //忽略的属性

@end

@interface SInfo : NSObject

@property (assign, nonatomic) NSInteger sId;
@property (assign, nonatomic) NSInteger age;

@end
