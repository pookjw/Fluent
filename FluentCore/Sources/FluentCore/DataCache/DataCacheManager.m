//
//  DataCacheManager.m
//  
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "DataCacheManager.h"

@interface DataCacheManager ()
@property (retain) NSOperationQueue *queue;
@property (retain) NSPersistentContainer *container;
@property (retain) NSManagedObjectContext *context;
@property (readonly, nonatomic) NSEntityDescription *dataCacheEntityDescription;
@end

@implementation DataCacheManager

+ (DataCacheManager *)sharedInstance {
    static DataCacheManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [DataCacheManager new];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
        [self.queue addOperationWithBlock:^{
            [self setupContainer];
            [self setupContext];
        }];
    }
    
    return self;
}

- (void)dealloc {
    [_queue cancelAllOperations];
    [_queue release];
    [_container release];
    [_context release];
    [super dealloc];
}

- (void)fetchDataCachesWithIdentity:(NSString *)identity completionHandler:(void (^)(NSArray<DataCache *> * _Nullable, NSError * _Nullable))completionHandler {
    [self.queue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataCache"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"identity", identity]];
        fetchRequest.predicate = predicate;
        
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<DataCache *> *results = [self.context executeFetchRequest:fetchRequest error:&error];
            if (error) {
                completionHandler(nil, error);
                return;
            }
            
            completionHandler(results, nil);
        }];
    }];
}

- (void)createDataCacheWithHandler:(void (^)(DataCache * _Nonnull))handler {
    [self.queue addOperationWithBlock:^{
        DataCache *dataCache = [[DataCache alloc] initWithContext:self.context];
        handler([dataCache autorelease]);
    }];
}

- (void)saveChangesWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [self.queue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            NSError * _Nullable __autoreleasing error = nil;
            [self.context save:&error];
            completionHandler(error);
        }];
    }];
}

- (void)deleteAllWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [self.queue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataCache"];
        NSBatchDeleteRequest *batchDeleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        batchDeleteRequest.affectedStores = self.container.persistentStoreCoordinator.persistentStores;
        batchDeleteRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
        
        NSError * _Nullable __autoreleasing error = nil;
        NSBatchDeleteResult *deletedObjectIDs = [self.container.persistentStoreCoordinator executeRequest:batchDeleteRequest withContext:self.context error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            completionHandler(error);
            return;
        }
        
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectIDsKey: deletedObjectIDs.result} intoContexts:@[self.context]];
        completionHandler(nil);
    }];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
    [queue release];
}

- (void)setupContainer {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
    managedObjectModel.entities = @[[self dataCacheEntityDescription]];
    
    NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"DataCacheManager" managedObjectModel:managedObjectModel];
    [managedObjectModel release];
    
    [container.persistentStoreDescriptions enumerateObjectsUsingBlock:^(NSPersistentStoreDescription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [container.persistentStoreCoordinator addPersistentStoreWithDescription:obj completionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
            NSAssert((error == nil), error.localizedDescription);
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    }];
    
    self.container = container;
    [container release];
}

- (void)setupContext {
    NSManagedObjectContext *context = self.container.newBackgroundContext;
    self.context = context;
    [context release];
}

- (NSEntityDescription *)dataCacheEntityDescription {
    NSEntityDescription *dataCacheEntityDescription = [NSEntityDescription new];
    dataCacheEntityDescription.name = NSStringFromClass(DataCache.class);
    dataCacheEntityDescription.managedObjectClassName = NSStringFromClass(DataCache.class);
    
    NSAttributeDescription *identityDescription = [NSAttributeDescription new];
    identityDescription.attributeType = NSStringAttributeType;
    identityDescription.optional = NO;
    identityDescription.transient = NO;
    identityDescription.name = @"identity";
    
    NSAttributeDescription *cacheDescription = [NSAttributeDescription new];
    cacheDescription.name = @"cache";
    cacheDescription.attributeType = NSBinaryDataAttributeType;
    cacheDescription.allowsExternalBinaryDataStorage = YES;
    cacheDescription.optional = YES;
    cacheDescription.transient = NO;
    
    dataCacheEntityDescription.properties = @[identityDescription, cacheDescription];
    [identityDescription release];
    [cacheDescription release];
    
    return [dataCacheEntityDescription autorelease];
}

@end
