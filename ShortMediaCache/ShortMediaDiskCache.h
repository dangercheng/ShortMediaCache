//
//  ShortMediaDiskCache.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShortMediaCacheConfig;

@interface ShortMediaDiskCache : NSObject

@property (nonatomic, copy) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

- (void)appendData:(NSData *)data tempFileWithName:(NSString *)fileName;

- (void)moveTempFileToFinalWithName:(NSString *)fileName;

- (BOOL)fileExistAtFinalWithName:(NSString *)fileName;

- (NSData *)dataFromOffset:(NSUInteger)offset
                    length:(NSUInteger)length
                  withName:(NSString *)fileName;

- (NSString *)createTempFileWithName:(NSString *)fileName;

- (NSInteger)tempCachedSizehWithName:(NSString *)fileName;

- (NSInteger)finalCachedSizeWithName:(NSString *)fileName;

- (NSInteger)totalCachedSize;

- (void)moveAllCacheToTrash;

- (void)cleanTrash;

- (void)resetCacheWithConfig:(ShortMediaCacheConfig *)config;

- (void)resetTempCacheWitchConfig:(ShortMediaCacheConfig *)config;

- (void)resetFinalCacheWitchConfig:(ShortMediaCacheConfig *)config;

@end
