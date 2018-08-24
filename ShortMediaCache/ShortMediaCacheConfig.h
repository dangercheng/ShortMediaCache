//
//  ShortMediaCacheConfig.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/16.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortMediaCacheConfig : NSObject
@property (nonatomic, assign) NSInteger maxTempCacheSize;
@property (nonatomic, assign) NSInteger maxFinalCacheSize;
@property (nonatomic, assign) NSInteger maxTempCacheTimeInterval;
@property (nonatomic, assign) NSInteger maxFinalCacheTimeInterval;

+ (instancetype)defaultConfig;
@end
