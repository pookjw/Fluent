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
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSError * _Nullable _error = nil;
        
        FluentWallaperProvider *provider = [[FluentWallaperProvider alloc] initWithCompletionHandler:^(NSArray<FluentWallpaper *> * _Nullable fluentWallpapers, NSError * _Nullable error) {
            if (error) {
                _error = [error retain];
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            WallpapersSnapshot *snapshot = [WallpapersSnapshot new];
            
            WallpapersSectionModel *fluentWallpapersSectionModel = [[WallpapersSectionModel alloc] initWithType:WallpapersSectionModelTypeFluentWallpapers];
            [snapshot appendSectionsWithIdentifiers:@[fluentWallpapersSectionModel]];
            
            [fluentWallpapers enumerateObjectsUsingBlock:^(FluentWallpaper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WallpapersItemModel *itemModel = [[WallpapersItemModel alloc] initWithFluentWallpaper:obj];
                [snapshot appendItemsWithIdentifiers:@[itemModel] intoSectionWithIdentifier:fluentWallpapersSectionModel];
                [itemModel release];
            }];
            
            [fluentWallpapersSectionModel release];
            
            ((void (*)(id, SEL, id, BOOL, id))objc_msgSend)(dataSource, NSSelectorFromString(@"applySnapshot:animatingDifferences:completion:"), snapshot, YES, ^{
                dispatch_semaphore_signal(semaphore);
            });
            
            [snapshot release];
        }];
        
        [operation observeValueForKeyPath:@"isCancelled" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew changeHandler:^(id  _Nonnull object, NSDictionary * _Nonnull changes) {
            if (((NSNumber *)changes[NSKeyValueChangeNewKey]).boolValue) {
                [provider cancel];
            }
        }];
        
        [provider start];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
        [provider release];
        
        completionHandler(_error);
        [_error release];
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
