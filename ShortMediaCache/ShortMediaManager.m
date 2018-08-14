//
//  ShortMediaManager.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/31.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaManager.h"

@implementation ShortMediaManager
+ (instancetype)shareManager {
    static ShortMediaManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ShortMediaManager alloc] init];
    });
    return manager;
}

- (void)loadMediaWithUrl:(NSURL *)url
                 options:(ShortMediaOptions)options
                progress:(ShortMediaProgressBlock)progress
              completion:(ShortMediaCompletionBlock)completion {
    [[ShortMediaDownloader shareDownloader] downloadMediaWithUrl:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(progress) progress(receivedSize, expectedSize);
        });
    } completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) completion(error);
        });
    }];
}

- (void)endLoadMediaWithUrl:(NSURL *)url {
    [[ShortMediaDownloader shareDownloader] cancelDownloadWithUrl:url];
}

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url {
    return [[ShortMediaCache shareCache] cacheDataFromOffset:offset length:length withUrl:url];
}

@end
