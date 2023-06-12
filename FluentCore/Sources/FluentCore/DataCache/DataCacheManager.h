//
//  DataCacheManager.h
//  
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <Foundation/Foundation.h>
#import "DataCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataCacheManager : NSObject
@property (class, readonly) DataCacheManager *sharedInstance;
@property (readonly, retain) NSOperationQueue *queue;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)fetchDataCachesWithIdentity:(NSString *)identity completionHandler:(void (^)(NSArray<DataCache *> * _Nullable __autoreleasing dataCaches, NSError * _Nullable __autoreleasing error))completionHandler;
- (void)createDataCacheWithHandler:(void (^)(DataCache * __autoreleasing dataCache))handler;
- (void)saveChangesWithCompletionHandler:(void (^)(NSError * _Nullable __autoreleasing))completionHandler;
- (void)destoryWithCompletionHandler:(void (^)(NSError * _Nullable __autoreleasing error))completionHandler;
@end

NS_ASSUME_NONNULL_END
