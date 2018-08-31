//
//  ShortMediaManager.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaDownloader.h"
#import "ShortMediaCacheConfig.h"

@interface ShortMediaManager : NSObject

@property (nonatomic, strong) ShortMediaCacheConfig *cacheConfig;

@property (nonatomic, strong, readonly) NSArray *prloadingMediaUrls;

+ (instancetype)shareManager;

- (void)loadMediaWithUrl:(NSURL *)url
                 options:(ShortMediaOptions)options
                progress:(ShortMediaProgressBlock)progress
              completion:(ShortMediaCompletionBlock)completion;

- (void)endLoadMediaWithUrl:(NSURL *)url;

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url;

- (NSInteger)totalCachedSize;

- (NSString *)totalCachedSizeStr;

- (void)cleanCache;

- (void)resetPreloadingWithMediaUrls:(NSArray<NSURL *> *)mediaUrls;

@end
