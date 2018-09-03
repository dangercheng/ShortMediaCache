//
//  ShortMediaCache.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaCache.h"
#import <CommonCrypto/CommonDigest.h>

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define UnLock() dispatch_semaphore_signal(self->_lock)


@implementation ShortMediaCache {
    NSMutableDictionary *_urlFileNameCache;
    dispatch_queue_t _fileQueue;
    dispatch_semaphore_t _lock;
}

+ (instancetype)shareCache {
    static ShortMediaCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"com.DandJ.shortMedia"];
        ShortMediaDiskCache *diskCache = [[ShortMediaDiskCache alloc] initWithPath:cachePath];
        cache = [[ShortMediaCache alloc] initWithDiskCache:diskCache];
    });
    return cache;
}

#pragma mark - pubulic
- (instancetype)initWithDiskCache:(ShortMediaDiskCache *)diskCache {
    self = [super init];
    if(!self) return nil;
    self.diskCache = diskCache;
    _lock = dispatch_semaphore_create(1);
    _urlFileNameCache = [NSMutableDictionary dictionary];
    _fileQueue = dispatch_queue_create("com.DandJ.shortMedia.cache", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (NSString *)createCacheFileWithUrl:(NSURL *)url {
    if(!url) {
        return nil;
    }
    Lock();
    NSString *fileName = [self fileNameWithUrl:url];
    NSString *filePath = [_diskCache createTempFileWithName:fileName];
    UnLock();
    return filePath;
}

- (void)appendWithData:(NSData *)data url:(NSURL *)url {
    __weak typeof(self) _self = self;
    dispatch_async(_fileQueue, ^{
        __strong typeof(_self) self = _self;
        if(!self) return;
        Lock();
        NSString *fileName = [self fileNameWithUrl:url];
        [self.diskCache appendData:data tempFileWithName:fileName];
        UnLock();
    });
}

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url {
    Lock();
    NSString *fileName = [self fileNameWithUrl:url];
    NSData *retData = [_diskCache dataFromOffset:offset length:length withName:fileName];
    UnLock();
    return retData;
}

- (void)cacheCompletedWithUrl:(NSURL *)url {
    NSString *fileName = [self fileNameWithUrl:url];
    __weak typeof(self) _self = self;
    dispatch_sync(_fileQueue, ^{
        __strong typeof(_self) self = _self;
        if(!self) return;
        Lock();
        [self.diskCache moveTempFileToFinalWithName:fileName];
        UnLock();
    });
}

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url {
    NSString *fileName = [self fileNameWithUrl:url];
    Lock();
    BOOL ret = [_diskCache fileExistAtFinalWithName:fileName];
    UnLock();
    return ret;
}

- (NSInteger)cachedSizeWithUrl:(NSURL *)url {
    NSString *fileName = [self fileNameWithUrl:url];
    Lock();
    NSInteger size = [_diskCache tempCachedSizehWithName:fileName];
    UnLock();
    return size;
}

- (NSInteger)finalCachedSizeWithUrl:(NSURL *)url {
    NSString *fileName = [self fileNameWithUrl:url];
    Lock();
    NSInteger size = [_diskCache finalCachedSizeWithName:fileName];
    UnLock();
    return size;
}

- (NSInteger)totalCachedSize {
    Lock();
    NSInteger size = [_diskCache totalCachedSize];
    UnLock();
    return size;
}

- (void)cleanCache {
    Lock();
    [_diskCache moveAllCacheToTrash];
    UnLock();
    __weak typeof(self) _self = self;
    dispatch_async(_fileQueue, ^{
        __strong typeof(_self) self = _self;
        if(!self) return;
        Lock();
        [self.diskCache cleanTrash];
        UnLock();
    });
}

- (void)resetCacheWithConfig:(ShortMediaCacheConfig *)cacheConfig completion:(CompletionBlock)completion {
   __weak typeof(self) _self = self;
    dispatch_async(_fileQueue, ^{
        __strong typeof(_self) self = _self;
        if(!self) return;
        Lock();
        [self.diskCache resetCacheWithConfig:cacheConfig];
        UnLock();
        
        if(completion) {
            completion();
        }
    });
}

- (void)resetFinalCacheWithConfig:(ShortMediaCacheConfig *)cacheConfig completion:(CompletionBlock)completion {
    __weak typeof(self) _self = self;
    dispatch_async(_fileQueue, ^{
        __strong typeof(_self) self = _self;
        if(!self) return;
        
        Lock();
        [self.diskCache resetFinalCacheWitchConfig:cacheConfig];
        UnLock();
        
        if(completion) {
            completion();
        }
    });
}


#pragma mark - private
- (NSString *)fileNameWithUrl:(NSURL *)url {
    NSString *fileName = [_urlFileNameCache objectForKey:url];
    if(!fileName) {
        fileName = [NSString stringWithFormat:@"%@.%@", [self md5:url.absoluteString], url.pathExtension];
        [_urlFileNameCache setObject:fileName forKey:url];
    }
    return fileName;
}

- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
