//
//  NetworkDownloader.m
//
//
//  Created by Jinwoo Kim on 6/12/23.
//

#import "NetworkDownloader.h"
#import "../DataCache/DataCacheManager.h"

static NSProgressUserInfoKey NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey = @"NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey";
static NSProgressUserInfoKey NSProgressUserInfoNetworkDownloaderCompletionHandlerKey = @"NSProgressUserInfoNetworkDownloaderCompletionHandler";

typedef void (^NSProgressUserInfoNetworkDownloaderDidReceiveHandler)(NSProgress *progress, NSData *data);
typedef void (^NSProgressUserInfoNetworkDownloaderCompletionHandler)(NSProgress *progress, NSError * _Nullable __autoreleasing error);

@interface NetworkDownloaderHelper : NSObject <NSURLSessionDataDelegate>
@end

@implementation NetworkDownloaderHelper

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSProgressUserInfoNetworkDownloaderDidReceiveHandler handler = dataTask.progress.userInfo[NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey];
    handler(dataTask.progress, data);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSProgressUserInfoNetworkDownloaderCompletionHandler handler = task.progress.userInfo[NSProgressUserInfoNetworkDownloaderCompletionHandlerKey];
    handler(task.progress, error);
    
    // Prevent Retain Cycle
    [task.progress setUserInfoObject:nil forKey:NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey];
    [task.progress setUserInfoObject:nil forKey:NSProgressUserInfoNetworkDownloaderCompletionHandlerKey];
}

@end

@interface NetworkDownloader ()
@property (retain) DataCacheManager *dataCacheManager;
@end

@implementation NetworkDownloader

- (instancetype)init {
    if (self = [super init]) {
        [self setupDataCacheManager];
    }
    
    return self;
}

- (void)dealloc {
    [_dataCacheManager release];
    [super dealloc];
}

- (void)downloadFromURL:(NSURL *)url userInfo:(NSDictionary * _Nullable)userInfo didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [self downloadWithRequest:request userInfo:userInfo didReceiveDataHandler:didReceiveDataHandler];
    [request release];
}

- (void)downloadWithRequest:(NSURLRequest *)request userInfo:(NSDictionary * _Nullable)userInfo didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler {
    DataCacheManager *dataCacheManager = self.dataCacheManager;
    
    [self.dataCacheManager fetchDataCachesWithIdentity:request.URL.absoluteString completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
        if (error) {
            didReceiveDataHandler(nil, nil, userInfo, error);
            return;
        }
        
        NSData * _Nullable cachedData = dataCaches.lastObject.data;
        if (cachedData) {
            didReceiveDataHandler(nil, cachedData, userInfo, nil);
            return;
        }
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        
        NetworkDownloaderHelper *helper = [NetworkDownloaderHelper new];
        task.delegate = helper;
        [helper release];
        
        NSMutableData *partialData = [NSMutableData new];
        NSProgressUserInfoNetworkDownloaderDidReceiveHandler _didReceiveHandler = ^(NSProgress *progress, NSData *data) {
            [partialData appendData:data];
            if (!progress.isFinished && !progress.isCancelled) {
                didReceiveDataHandler(progress, partialData, userInfo, nil);
            }
        };
        [task.progress setUserInfoObject:[[_didReceiveHandler copy] autorelease] forKey:NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey];
        
        NSProgressUserInfoNetworkDownloaderCompletionHandler _completionHandler = ^(NSProgress *progress, NSError * _Nullable __autoreleasing error) {
            if (error) {
                didReceiveDataHandler(progress, partialData, userInfo, error);
            }
            
            [dataCacheManager fetchDataCachesWithIdentity:request.URL.absoluteString completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
                if (error) {
                    didReceiveDataHandler(progress, partialData, userInfo, error);
                    return;
                }
                
                DataCache * _Nullable dataCache = dataCaches.lastObject;
                if (dataCache) {
                    dataCache.data = partialData;
                    [dataCacheManager saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
                        didReceiveDataHandler(progress, partialData, userInfo, error);
                    }];
                } else {
                    [dataCacheManager createDataCacheWithHandler:^(DataCache * _Nonnull dataCache) {
                        dataCache.identity = request.URL.absoluteString;
                        dataCache.data = partialData;
                        [dataCacheManager saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
                            didReceiveDataHandler(progress, partialData, userInfo, error);
                        }];
                    }];
                }
            }];
        };
        [task.progress setUserInfoObject:[[_completionHandler copy] autorelease] forKey:NSProgressUserInfoNetworkDownloaderCompletionHandlerKey];
        
        [partialData release];
        [task resume];
        [session finishTasksAndInvalidate];
    }];
}

- (void)setupDataCacheManager {
    self.dataCacheManager = DataCacheManager.sharedInstance;
}

@end
