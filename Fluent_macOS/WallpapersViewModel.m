//
//  WallpapersViewModel.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersViewModel.h"
#import <objc/message.h>
@import FluentCore;

@interface WallpapersViewModel ()
@property (retain) WallpapersDataSource *dataSource;
@property (retain) NSOperationQueue *queue;
@end

@implementation WallpapersViewModel

- (instancetype)initWithDataSource:(WallpapersDataSource *)dataSource {
    if (self = [self init]) {
        self.dataSource = dataSource;
        [self setupQueue];
    }
    
    return self;
}

- (void)dealloc {
    [_queue cancelAllOperations];
    [_queue release];
    [_dataSource release];
    [super dealloc];
}

- (void)loadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    NSOperationQueue *queue = self.queue;
    WallpapersDataSource *dataSource = self.dataSource;
    
    __block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        FluentWallaperProvider *provider = [[FluentWallaperProvider alloc] initWithCompletionHandler:^(NSArray<FluentWallpaper *> * _Nullable fluentWallpapers, NSError * _Nullable error) {
            NSLog(@"%@", fluentWallpapers);
        }];
        
        [provider start];
        [provider release];
    }];
    
    [queue addOperation:operation];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
    [queue release];
}

@end
