//
//  ShortMediaResourceLoader.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ShortMediaResourceLoader.h"
#import "AVAssetResourceLoadingDataRequest+ShortMediaCache.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShortMediaResourceLoader()<AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) NSInteger receivedSize;
@property (nonatomic, assign) ShortMediaOptions options;
@end

@implementation ShortMediaResourceLoader

- (instancetype)init {
    self = [super init];
    if(!self) return nil;
    _pendingRequests = [NSMutableArray array];
    return self;
}

- (instancetype)initWithDelegate:(id<ShortMediaResourceLoaderDelegate>)delegate {
    _delegate = delegate;
    return [self init];
}

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url {
    return [self playItemWithUrl:url options:kNilOptions];
}

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url options:(ShortMediaOptions)options {
    _url = url;
    _options = options;
    [self startLoading];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self unRecognizerUrl] options:nil];
    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    return item;
}

- (void)startLoading {
    __weak typeof(self) _self = self;
    [[ShortMediaManager shareManager] loadMediaWithUrl:_url options:_options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        __strong typeof(_self) self = _self;
        if(!self) return;
        self.receivedSize = receivedSize;
        self.expectedSize = expectedSize;
        [self dealPendingRequests];
    } completion:^(NSError *error) {
        __strong typeof(_self) self = _self;
        if(!self) return;
        if(!error) {
            self.receivedSize = self.expectedSize;
        }
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
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (resourceLoader && loadingRequest) {
        loadingRequest.dataRequest.respondedSize = 0;
        [self.pendingRequests addObject:loadingRequest];
        [self dealPendingRequests];
    }
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (!loadingRequest.isFinished) {
        [loadingRequest finishLoadingWithError:[self loaderCancelledError]];
    }
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - private
- (void)dealPendingRequests {
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

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    NSInteger startOffset = (NSInteger)dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = (NSInteger)dataRequest.currentOffset;
    }
    startOffset = MAX(0, startOffset);
    if(startOffset > _receivedSize) {
        return NO;
    }
    NSInteger canReadsize = _receivedSize - startOffset;
    canReadsize = MAX(0, canReadsize);
    NSInteger realReadSize = MIN(dataRequest.requestedLength, canReadsize);
    NSData *respondData = [NSData data];
    if(realReadSize > 2) {
        NSData *cacheData = [[ShortMediaManager shareManager] cacheDataFromOffset:startOffset length:realReadSize withUrl:_url];
        if(cacheData) {
            respondData = cacheData;
        }
    }
    dataRequest.respondedSize += realReadSize;
    [dataRequest respondWithData:respondData];
    if(dataRequest.respondedSize >= dataRequest.requestedLength) {
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
