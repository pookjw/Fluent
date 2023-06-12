//
//  NetworkDownloader.m
//  
//
//  Created by Jinwoo Kim on 6/12/23.
//

#import "NetworkDownloader.h"
#import "../DataCache/DataCacheManager.h"

static NSProgressUserInfoKey NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey = @"NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey";

@interface NetworkDownloaderHelper : NSObject <NSURLSessionDataDelegate>
@end

@implementation NetworkDownloaderHelper

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NetworkDownloaderDidReceiveDataHandler handler = dataTask.progress.userInfo[NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey];
    handler(dataTask.progress, data, YES, nil);
}

@end

@interface NetworkDownloader ()
@property (retain) DataCacheManager *dataCacheManager;
@property (retain) NSOperationQueue *queue;
@property (retain) NSMutableArray<NSURLSessionTask *> *tasks;
@end

@implementation NetworkDownloader

- (instancetype)init {
    if (self = [super init]) {
        [self setupDataCacheManager];
        [self setupQueue];
        [self setupTasks];
    }
    
    return self;
}

- (void)dealloc {
    [_queue cancelAllOperations];
    [_queue release];
    [_dataCacheManager release];
    [_tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [_tasks release];
    [super dealloc];
}

- (void)downloadFromURL:(NSURL *)url didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [self downloadWithRequest:request didReceiveDataHandler:didReceiveDataHandler];
    [request release];
}

- (void)downloadWithRequest:(NSURLRequest *)request didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler {
    NSOperationQueue *queue = self.queue;
    NSMutableArray<NSURLSessionTask *> *tasks = self.tasks;
    DataCacheManager *dataCacheManager = self.dataCacheManager;
    
    [self.dataCacheManager fetchDataCachesWithIdentity:request.URL.absoluteString completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
        if (error) {
            didReceiveDataHandler(nil, nil, NO, error);
            return;
        }
        
        NSData * _Nullable cachedData = dataCaches.lastObject.data;
        if (cachedData) {
            didReceiveDataHandler(nil, cachedData, NO, nil);
            return;
        }
        
        [queue addOperationWithBlock:^{
            NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
            
            __block NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSProgress *progress = task.progress;
                
                if (data) {
                    [dataCacheManager fetchDataCachesWithIdentity:request.URL.absoluteString completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
                        if (error) {
                            didReceiveDataHandler(progress, data, YES, error);
                            return;
                        }
                        
                        DataCache * _Nullable dataCache = dataCaches.lastObject;
                        if (dataCache) {
                            dataCache.data = data;
                            [dataCacheManager saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
                                didReceiveDataHandler(progress, data, YES, error);
                            }];
                        } else {
//                            [dataCacheManager createDataCacheWithHandler:^(DataCache * _Nonnull dataCache) {
//                                dataCache.identity = request.URL.absoluteString;
//                                dataCache.data = data;
//                                [dataCacheManager saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
//                                    didReceiveDataHandler(progress, data, YES, error);
//                                }];
//                            }];
                            didReceiveDataHandler(progress, data, YES, error);
                        }
                    }];
                } else {
                    didReceiveDataHandler(progress, nil, YES, error);
                }
            }];
            
            NetworkDownloaderHelper *helper = [NetworkDownloaderHelper new];
            
            task.delegate = helper;
            [helper release];
            [task.progress setUserInfoObject:didReceiveDataHandler forKey:NSProgressUserInfoNetworkDownloaderDidReceiveHandlerKey];
            [tasks addObject:task];
            [task resume];
        }];
    }];
}

- (void)setupDataCacheManager {
    self.dataCacheManager = DataCacheManager.sharedInstance;
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUtility;
    self.queue = queue;
    [queue release];
}

- (void)setupTasks {
    NSMutableArray<NSURLSessionTask *> *tasks = [NSMutableArray<NSURLSessionTask *> new];
    self.tasks = tasks;
    [tasks release];
}

@end
