//
//  ShortMediaDownloadOperation.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaDownloadOperation.h"

@interface ShortMediaDownloadOperation()
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite) BOOL started;

@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) NSInteger receivedSize;

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, weak) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, copy) ShortMediaProgressBlock progress;
@property (nonatomic, copy) ShortMediaCompletionBlock completion;

@end

@implementation ShortMediaDownloadOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithRequest:(NSURLRequest *)request
                        session:(NSURLSession *)session
                       progress:(ShortMediaProgressBlock)progress
                     completion:(ShortMediaCompletionBlock)completion {
    self = [super init];
    if (!self) return nil;
    _request = request;
    _session = session;
    _progress = progress;
    _completion = completion;
    _executing = NO;
    _finished = NO;
    _cancelled = NO;
    _started = NO;
    return self;
}

- (void)dealloc {
    [self finish];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [[ShortMediaCache shareCache] cacheCompletedWithUrl:_request.URL];
    if (_completion) _completion(error);
    NSLog(@"ShortMediaDownloadOperation donwload complete: %@", _request.URL.absoluteString);
    [self finish];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        [[ShortMediaCache shareCache] createCacheFileWithUrl:_request.URL];
    }
    else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:nil];
        [self cancelOperation];
        if(_completion) _completion(error);
        [self finish];
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[ShortMediaCache shareCache] appendWithData:data url:_request.URL];
    _receivedSize += data.length;
    if(_progress) _progress(_receivedSize, _expectedSize);
    
//    NSLog(@"ShortMediaDownloadOperation data: _receivedSize=%ld, _expectedSize=%ld",_receivedSize, _expectedSize);
}

#pragma mark - Methods
- (void)start {
    [_lock lock];
    self.started = YES;
    if([self isCancelled]) {
        [self cancelOperation];
    } else if([self isReady] && ![self isFinished] && ![self isExecuting]) {
        if(!_request) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            if(_completion) _completion(error);
            [self finish];
        } else {
            self.executing = YES;
            _dataTask = [_session dataTaskWithRequest:_request];
            [_dataTask resume];
            NSLog(@"ShortMediaDownloadOperation start donwload: %@", _request.URL.absoluteString);
        }
    }
    [_lock unlock];
}

- (void)cancel {
    [_lock lock];
    if(![self isCancelled]) {
        [super cancel];
        self.cancelled = YES;
        if ([self isExecuting]) {
            self.executing = NO;
            [self cancelOperation];
        }
        if(self.started) {
            self.finished = YES;
        }
    }
    [_lock unlock];
}

- (void)cancelOperation {
    if(_dataTask) {
        [_dataTask cancel];
        _dataTask = nil;
        NSError *cancelError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
        if(_completion) _completion(cancelError);
        [self finish];
    }
}

- (void)finish {
    self.finished = YES;
    self.executing = NO;
}

- (void)setExecuting:(BOOL)executing {
    [_lock lock];
    if(_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
}

- (BOOL)isExecuting {
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}

- (void)setFinished:(BOOL)finished {
    [_lock lock];
    if(!_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}

- (BOOL)isFinished {
    [_lock lock];
    BOOL finished = _finished;
    [_lock unlock];
    return finished;
}

- (void)setCancelled:(BOOL)cancelled {
    [_lock lock];
    if(!_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
}

- (BOOL)isCancelled {
    [_lock lock];
    BOOL cancelled = _cancelled;
    [_lock unlock];
    return cancelled;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if([key isEqualToString:@"isExecuting"] ||
       [key isEqualToString:@"isFinished"] ||
       [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return YES;
}

@end
