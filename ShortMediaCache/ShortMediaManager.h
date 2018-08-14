//
//  ShortMediaManager.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaDownloader.h"

@interface ShortMediaManager : NSObject

@property (nonatomic, strong) ShortMediaCache *cache;

+ (instancetype)shareManager;

- (void)loadMediaWithUrl:(NSURL *)url
                 options:(ShortMediaOptions)options
                progress:(ShortMediaProgressBlock)progress
              completion:(ShortMediaCompletionBlock)completion;

- (void)endLoadMediaWithUrl:(NSURL *)url;

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url;

@end
