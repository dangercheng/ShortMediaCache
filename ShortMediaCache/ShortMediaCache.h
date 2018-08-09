//
//  ShortMediaCache.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaDiskCache.h"

@interface ShortMediaCache : NSObject

@property (nonatomic, strong) ShortMediaDiskCache *diskCache;

+ (instancetype)shareCache;

- (NSString *)createCacheFileWithUrl:(NSURL *)url;

- (void)appendWithData:(NSData *)data url:(NSURL *)url;

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url;

- (void)cacheCompletedWithUrl:(NSURL *)url;

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url;

- (NSInteger)cachedSizeWithUrl:(NSURL *)url;

- (NSInteger)finalCachedSizeWithUrl:(NSURL *)url;

@end
