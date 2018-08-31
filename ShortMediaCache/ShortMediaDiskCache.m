//
//  ShortMediaDiskCache.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaDiskCache.h"
#import "ShortMediaCacheConfig.h"

static NSString *const kMediaFinalDirectoryName = @"media";
static NSString *const kMediaTempDirectoryName = @"temp";
static NSString *const kMediaTrashDirectoryName = @"trash";

@implementation ShortMediaDiskCache {
    NSString *_finalPath;
    NSString *_tempPath;
    NSString *_trashPath;
    CFMutableDictionaryRef _fileHandleCache;
}


- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if(!self) return nil;
    _path = path;
    _finalPath = [path stringByAppendingPathComponent:kMediaFinalDirectoryName];
    _tempPath = [path stringByAppendingPathComponent:kMediaTempDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kMediaTrashDirectoryName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    _fileHandleCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:_finalPath withIntermediateDirectories:YES attributes:nil error:&error] ||
       ![fileManager createDirectoryAtPath:_tempPath withIntermediateDirectories:YES attributes:nil error:&error] ||
       ![fileManager createDirectoryAtPath:_trashPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        return nil;
    }
    
    NSLog(@"ShortMediaCache tempPath:%@", _tempPath);
    NSLog(@"ShortMediaCache finalPath:%@", _finalPath);
    NSLog(@"ShortMediaCache trashPath:%@",_trashPath);
    return self;
}

- (void)dealloc {
    if (_fileHandleCache) CFRelease(_fileHandleCache);
    _fileHandleCache = NULL;
}

- (NSString *)createTempFileWithName:(NSString *)fileName {
    NSString *filePath = [_tempPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

- (void)appendData:(NSData *)data tempFileWithName:(NSString *)fileName {
    if(!data) {
        return;
    }
    if(!(fileName.length > 0)) {
        return;
    }
    NSString *filePath = [_tempPath stringByAppendingPathComponent:fileName];
    NSFileHandle *fileHandle = CFDictionaryGetValue(_fileHandleCache, (__bridge const void *)(fileName));
    if(!fileHandle) {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        CFDictionarySetValue(_fileHandleCache, (__bridge const void *)(fileName), (__bridge const void *)(fileHandle));
    }
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
}

- (void)moveTempFileToFinalWithName:(NSString *)fileName {
    if(!(fileName.length > 0)) {
        return;
    }
    NSString *tempFilePath = [_tempPath stringByAppendingPathComponent:fileName];
    NSString *finalFilePath = [_finalPath stringByAppendingPathComponent:fileName];
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager moveItemAtPath:tempFilePath toPath:finalFilePath error:&error];
    if(!error) {
        CFDictionaryRemoveValue(_fileHandleCache, (__bridge const void *)(fileName));
    }
}

- (NSData *)dataFromOffset:(NSUInteger)offset
                    length:(NSUInteger)length
                  withName:(NSString *)fileName {
    if(!(fileName.length > 0)) {
        return nil;
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *tempFileFath = [_tempPath stringByAppendingPathComponent:fileName];
    NSString *finalFilePath = [_finalPath stringByAppendingPathComponent:fileName];
    
    NSString *targetPath = tempFileFath;
    BOOL fileExist = [fileManager fileExistsAtPath:finalFilePath];
    if(fileExist) {
        targetPath = finalFilePath;
    } else {
        fileExist = [fileManager fileExistsAtPath:tempFileFath];
        if(!fileExist) {
            return nil;
        }
    }
    
    NSError *error;
    NSData *tempVideoData = [NSData dataWithContentsOfFile:targetPath options:NSDataReadingMappedIfSafe error:&error];
    if (!error && !(tempVideoData.length < (offset + length))) {
        NSRange respondRange = NSMakeRange(offset, length);
        return [tempVideoData subdataWithRange:respondRange];
    } else {
        return nil;
    }
}

- (NSInteger)finalCachedSizeWithName:(NSString *)fileName {
    NSString *path = [_finalPath stringByAppendingPathComponent:fileName];
    return [self fileSizeWithPath:path];
}

- (NSInteger)tempCachedSizehWithName:(NSString *)fileName {
    NSString *path = [_tempPath stringByAppendingPathComponent:fileName];
    return [self fileSizeWithPath:path];
}

- (NSInteger)fileSizeWithPath:(NSString *)filePath {
    if(!(filePath.length > 0)) {
        return 0;
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(![fileManager fileExistsAtPath:filePath]) {
        return 0;
    }
    NSError *error = nil;
    NSInteger fileSize = 0;
    NSDictionary *fileDict = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (!error && fileDict) {
        fileSize = (NSInteger)[fileDict fileSize];
    }
    
    return fileSize;
}

- (BOOL)fileExistAtFinalWithName:(NSString *)fileName {
    if(!(fileName.length > 0)) {
        return NO;
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filePath = [_finalPath stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSInteger)totalCachedSize {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:_tempPath];
    NSInteger totalFileSize = 0;
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [_tempPath stringByAppendingPathComponent:fileName];
        NSInteger fileSize = [self fileSizeWithPath:filePath];
        totalFileSize += fileSize;
    }
    fileEnumerator = [fileManager enumeratorAtPath:_finalPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [_finalPath stringByAppendingPathComponent:fileName];
        NSInteger fileSize = [self fileSizeWithPath:filePath];
        totalFileSize += fileSize;
    }
    return totalFileSize;
}

- (void)moveAllCacheToTrash {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator_temp = [fileManager enumeratorAtPath:_tempPath];
    for (NSString *fileName in fileEnumerator_temp) {
        NSError *error;
        NSString *filePath = [_tempPath stringByAppendingPathComponent:fileName];
        NSString *toPath = [_trashPath stringByAppendingPathComponent:fileName];
        [fileManager moveItemAtPath:filePath toPath:toPath error:&error];
        if(!error) {
            CFDictionaryRemoveValue(_fileHandleCache, (__bridge const void *)(fileName));
        }
    }
    
    NSDirectoryEnumerator *fileEnumerator_full = [fileManager enumeratorAtPath:_finalPath];
    for (NSString *fileName in fileEnumerator_full) {
        NSError *error;
        NSString *filePath = [_finalPath stringByAppendingPathComponent:fileName];
        NSString *toPath = [_trashPath stringByAppendingPathComponent:fileName];
        [fileManager moveItemAtPath:filePath toPath:toPath error:nil];
        if(!error) {
            CFDictionaryRemoveValue(_fileHandleCache, (__bridge const void *)(fileName));
        }
    }
}

- (void)cleanTrash {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:_trashPath error:nil];
    [fileManager createDirectoryAtPath:_trashPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)resetCacheWithConfig:(ShortMediaCacheConfig *)config {
    [self resetTempCacheWitchConfig:config];
    [self resetFinalCacheWitchConfig:config];
}

- (void)resetTempCacheWitchConfig:(ShortMediaCacheConfig *)config {
    [self resetCacheWithPath:_tempPath maxTimeInterval:config.maxTempCacheTimeInterval maxSize:config.maxTempCacheSize];
}

- (void)resetFinalCacheWitchConfig:(ShortMediaCacheConfig *)config {
    [self resetCacheWithPath:_finalPath maxTimeInterval:config.maxFinalCacheTimeInterval maxSize:config.maxFinalCacheSize];
}

- (void)resetCacheWithPath:(NSString *)path
           maxTimeInterval:(NSInteger)timeInterval
                    maxSize:(NSInteger)maxSize {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cacheUrl = [NSURL fileURLWithPath:path isDirectory:YES];
    NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:cacheUrl
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-timeInterval];
    NSMutableDictionary<NSURL *, NSDictionary<NSString *, id> *> *remainningFiles = [NSMutableDictionary dictionary];
    NSUInteger remainingSize = 0;
    
    NSMutableArray<NSURL *> *urlsToDelete = [[NSMutableArray alloc] init];
    
    for (NSURL *fileURL in fileEnumerator) {
        @autoreleasepool {
            NSError *error;
            NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
            if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            remainingSize += totalAllocatedSize.unsignedIntegerValue;
            remainningFiles[fileURL] = resourceValues;
        }
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        NSString *trashPath = [_trashPath stringByAppendingPathComponent:fileURL.lastPathComponent];
        [fileManager moveItemAtPath:fileURL.path toPath:trashPath error:nil];
    }
    
    if (maxSize > 0 && remainingSize > maxSize) {
        const NSUInteger targteCacheSize = maxSize / 2;
        NSArray<NSURL *> *sortedFiles = [remainningFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                 usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                     return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                                 }];
        
        for (NSURL *fileURL in sortedFiles) {
            NSString *trashPath = [_trashPath stringByAppendingPathComponent:fileURL.lastPathComponent];
            if([fileManager moveItemAtPath:fileURL.path toPath:trashPath error:nil]) {
                NSDictionary<NSString *, id> *resourceValues = remainningFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                remainingSize -= totalAllocatedSize.unsignedIntegerValue;
                
                if (remainingSize < targteCacheSize) {
                    break;
                }
            }
        }
    }
    [self cleanTrash];
}

@end
