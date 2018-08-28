//
//  ShortMediaDownloader.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/7.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaDownloader.h"
#import "ShortMediaDownloadOperation.h"

#define Lock() dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER)
#define UnLock() dispatch_semaphore_signal(self.lock)

@interface ShortMediaDownloader()<NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *operationCache;

@property (nonatomic, strong) dispatch_semaphore_t lock;
@end

@implementation ShortMediaDownloader

+ (instancetype)shareDownloader {
    static ShortMediaDownloader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ShortMediaDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(!self) return nil;
    _lock = dispatch_semaphore_create(1);
    _queue = [NSOperationQueue new];
    _operationCache = [NSMutableDictionary dictionary];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return self;
}

- (void)downloadMediaWithUrl:(NSURL *)url
                     options:(ShortMediaOptions)options
                    progress:(ShortMediaProgressBlock)progress
                  completion:(ShortMediaCompletionBlock)completion {
    [self downloadMediaWithUrl:url options:options preload:NO progress:progress completion:completion];
}

- (void)preloadMediaWithUrl:(NSURL *)url
                    options:(ShortMediaOptions)options
                   progress:(ShortMediaProgressBlock)progress
                 completion:(ShortMediaCompletionBlock)completion {
    [self downloadMediaWithUrl:url options:options preload:YES progress:progress completion:completion];
}

- (void)downloadMediaWithUrl:(NSURL *)url
                     options:(ShortMediaOptions)options
                     preload:(BOOL)preload
                    progress:(ShortMediaProgressBlock)progress
                  completion:(ShortMediaCompletionBlock)completion {
    BOOL cached = [[ShortMediaCache shareCache] isCacheCompletedWithUrl:url];
    if(cached) {
        NSInteger fileSize = [[ShortMediaCache shareCache] finalCachedSizeWithUrl:url];
        if(progress) progress(fileSize, fileSize);
        if(completion) completion(nil);
        return;
    }
    
    [self cancelDownloadWithUrl:url];
    NSInteger cachedSize = [[ShortMediaCache shareCache] cachedSizeWithUrl:url];
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-", (long)cachedSize];
    [downloadRequest setValue:range forHTTPHeaderField:@"Range"];
    downloadRequest.HTTPShouldHandleCookies = (options & ShortMediaOptionsHandleCookies);
    downloadRequest.HTTPShouldUsePipelining = YES;
    
    __weak typeof(self) _self = self;
    ShortMediaDownloadOperation *downloadOperation = [[ShortMediaDownloadOperation alloc] initWithRequest:downloadRequest session:_session options:options progress:progress completion:^(NSError *error) {
        __strong typeof(_self) self = _self;
        if(!self) return;
        Lock();
        [self.operationCache removeObjectForKey:url];
        UnLock();
        if(completion) completion(error);
    }];
    if(_userName && _password) {
        downloadOperation.credential = [NSURLCredential credentialWithUser:_userName password:_password persistence:NSURLCredentialPersistenceForSession];
    }
    downloadOperation.isPreloading = preload;
    Lock();
    if(!preload) {
        NSMutableArray *needCancelUrls = [NSMutableArray array];
        for (NSURL *url in _operationCache.allKeys) {
            ShortMediaDownloadOperation *operation = _operationCache[url];
            if(operation.isPreloading) {
                [needCancelUrls addObject:url];
            }
        }
        for (NSURL *url in needCancelUrls) {
            [_operationCache removeObjectForKey:url];
        }
    }
    [_operationCache setObject:downloadOperation forKey:url];
    [_queue addOperation:downloadOperation];
    UnLock();
}

- (void)cancelDownloadWithUrl:(NSURL *)url {
    if(!url) {
        return;
    }
    Lock();
    ShortMediaDownloadOperation *operation = [_operationCache objectForKey:url];
    if(operation) {
        [operation cancel];
        [_operationCache removeObjectForKey:url];
    }
    UnLock();
}

- (BOOL)canPreload {
    BOOL retValue = YES;
    Lock();
    for (ShortMediaDownloadOperation *operation in self.operationCache.allValues) {
        if(!operation.isPreloading) {
            retValue = NO;
            break;
        }
    }
    UnLock();
    return retValue;
}

- (void)dealloc {
    [_session invalidateAndCancel];
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    Lock();
    ShortMediaDownloadOperation *operation = [_operationCache objectForKey:task.originalRequest.URL];
    UnLock();
    [operation URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    ShortMediaDownloadOperation *operation = [_operationCache objectForKey:task.originalRequest.URL];
    [operation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    Lock();
    ShortMediaDownloadOperation *operation = [_operationCache objectForKey:dataTask.originalRequest.URL];
    UnLock();
    [operation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    Lock();
    ShortMediaDownloadOperation *operation = [_operationCache objectForKey:dataTask.originalRequest.URL];
    UnLock();
    [operation URLSession:session dataTask:dataTask didReceiveData:data];
}

@end
