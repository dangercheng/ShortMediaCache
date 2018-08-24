//
//  ShortMediaCacheConfig.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/16.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaCacheConfig.h"

@implementation ShortMediaCacheConfig

+ (instancetype)defaultConfig {
    ShortMediaCacheConfig *config = [ShortMediaCacheConfig new];
    config.maxTempCacheSize = 1024 * 1024 * 100;//100MB
    config.maxFinalCacheSize = 1024 * 1024 * 200;//200MB
    config.maxTempCacheTimeInterval = 1 * 24 * 60 * 60;//1days
    config.maxFinalCacheTimeInterval = 1 * 24 * 60 * 60;//2days
    return config;
}

@end
