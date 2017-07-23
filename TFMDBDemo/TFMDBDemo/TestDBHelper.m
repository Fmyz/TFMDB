//
//  TestDBHelper.m
//  TFMDBDemo
//
//  Created by Liu on 2017/7/24.
//  Copyright © 2017年 Tan. All rights reserved.
//

#import "TestDBHelper.h"

@implementation TestDBHelper

+ (instancetype)helperInstance
{
    static TestDBHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!helper) {
            helper = [[TestDBHelper alloc] init];
        }
    });
    return helper;
}

@end
