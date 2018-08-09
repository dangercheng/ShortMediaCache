//
//  ShortMediaResourceLoader.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaResourceLoader.h"
#import "ShortMediaManager.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface ShortMediaResourceLoader()<AVAssetResourceLoaderDelegate>
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, assign) NSInteger expectedSize;
@end

@implementation ShortMediaResourceLoader

- (instancetype)init {
    self = [super init];
    if(!self) return nil;
    _pendingRequests = [NSMutableArray array];
    return self;
}

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url {
    _url = url;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self unRecognizerUrl] options:nil];
    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        [self startLoading];
    });
    return item;
}

- (void)startLoading {
    __weak typeof(self) _self = self;
    [[ShortMediaManager shareManager] loadMediaWithUrl:_url progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        __strong typeof(_self) self = _self;
        if(!self) return;
        self.expectedSize = expectedSize;
        [self dealPendingRequests];
    } completion:^(NSError *error) {
        __strong typeof(_self) self = _self;
        if(!self) return;
        [self dealPendingRequests];
    }];
}

- (void)endLoading {
    [[ShortMediaManager shareManager] endLoadMediaWithUrl:_url];
}

- (void)dealloc {
    [self endLoading];
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    if (resourceLoader && loadingRequest) {
        [self.pendingRequests addObject:loadingRequest];
        NSLog(@"ShortMediaResourceLoader recived reqeuet count: %d", [self.pendingRequests count]);
        [self dealPendingRequests];
    }
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    if (!loadingRequest.isFinished) {
        [loadingRequest finishLoadingWithError:[self loaderCancelledError]];
    }
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - private
- (void)dealPendingRequests {
    @autoreleasepool {
        NSMutableArray *finishedRequests = [NSMutableArray array];
        [self.pendingRequests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest *loadingRequest, NSUInteger idx, BOOL * _Nonnull stop) {
            [self fillInContentInformation:loadingRequest.contentInformationRequest];
            BOOL finish = [self respondWithDataForRequest:loadingRequest];
            if (finish) {
                [finishedRequests addObject:loadingRequest];
                [loadingRequest finishLoading];
            }
        }];
        if (finishedRequests.count) {
            [self.pendingRequests removeObjectsInArray:finishedRequests];
        }
    }
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    startOffset = MAX(0, startOffset);
    NSData *cacheData = [[ShortMediaManager shareManager] cacheDataFromOffset:startOffset length:dataRequest.requestedLength withUrl:_url];
    if(cacheData) {
        [dataRequest respondWithData:cacheData];
        return YES;
    } else {
        return NO;
    }
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest * _Nonnull)contentInformationRequest{
    if (contentInformationRequest && !contentInformationRequest.contentType && _expectedSize > 0) {
        NSString *fileExtension = [self.url pathExtension];
        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        NSString *contentTypeS = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
        if (!contentTypeS) {
            contentTypeS = @"application/octet-stream";
        }
        NSString *mimetype = contentTypeS;
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimetype), NULL);
        contentInformationRequest.byteRangeAccessSupported = YES;
        contentInformationRequest.contentType = CFBridgingRelease(contentType);
        contentInformationRequest.contentLength = _expectedSize;
    }
}

- (NSURL *)unRecognizerUrl {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:@"www.dandj.top"] resolvingAgainstBaseURL:NO];
    components.scheme = @"SystemCannotRecognition";
    return [components URL];
}

- (NSError *)loaderCancelledError{
    NSError *error = [[NSError alloc] initWithDomain:@"dandj.top"
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

@end
