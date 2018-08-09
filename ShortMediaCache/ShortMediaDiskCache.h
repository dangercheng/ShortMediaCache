//
//  ShortMediaDiskCache.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortMediaDiskCache : NSObject

@property (nonatomic, copy) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

- (NSString *)createTempFileWithName:(NSString *)fileName;

- (void)appendData:(NSData *)data tempFileWithName:(NSString *)fileName;

- (void)moveTempFileToFinalWithName:(NSString *)fileName;

- (NSData *)dataFromOffset:(NSUInteger)offset
                    length:(NSUInteger)length
                  withName:(NSString *)fileName;

- (NSInteger)tempCachedSizehWithName:(NSString *)fileName;

- (NSInteger)finalCachedSizeWithName:(NSString *)fileName;

- (BOOL)fileExistAtFinalWithName:(NSString *)fileName;

@end
