#import <XCTest/XCTest.h>
@import FluentCore;

@interface DataCacheManagerTests : XCTestCase
@end

@implementation DataCacheManagerTests

- (void)setUp {
    [super setUp];
    [self cleanup];
}

- (void)tearDown {
    [super tearDown];
    [self cleanup];
}

- (void)cleanup {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    [DataCacheManager.sharedInstance deleteAllWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:2.f];
}

- (void)test_init {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    DataCacheManager *manager = DataCacheManager.sharedInstance;
    [manager.queue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:2.f];
}

- (void)test_flow {
    NSString *identity = @"Test";
    XCTestExpectation *createExpectation = [self expectationWithDescription:@"create"];
    
    [DataCacheManager.sharedInstance createDataCacheWithHandler:^(DataCache * _Nonnull dataCache) {
        dataCache.identity = identity;
        
        [DataCacheManager.sharedInstance saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
            XCTAssertNil(error);
            [createExpectation fulfill];
        }];
    }];
    
    [self waitForExpectations:@[createExpectation] timeout:2.f];
    
    XCTestExpectation *fetchExpectation = [self expectationWithDescription:@"fetch"];
    
    [DataCacheManager.sharedInstance fetchDataCachesWithIdentity:identity completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue(dataCaches.count == 1);
        [fetchExpectation fulfill];
    }];
    
    [self waitForExpectations:@[fetchExpectation] timeout:2.f];
}

- (void)test_deleteAll {
    NSString *identity = @"Test";
    XCTestExpectation *createExpectation = [self expectationWithDescription:@"create"];
    
    [DataCacheManager.sharedInstance createDataCacheWithHandler:^(DataCache * _Nonnull dataCache) {
        dataCache.identity = identity;
        
        [DataCacheManager.sharedInstance saveChangesWithCompletionHandler:^(NSError * _Nullable error) {
            XCTAssertNil(error);
            [createExpectation fulfill];
        }];
    }];
    
    [self waitForExpectations:@[createExpectation] timeout:2.f];
    
    XCTestExpectation *deleteExpectation = [self expectationWithDescription:@"delete"];
    
    [DataCacheManager.sharedInstance deleteAllWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [deleteExpectation fulfill];
    }];
    
    [self waitForExpectations:@[deleteExpectation] timeout:2.f];
    
    XCTestExpectation *fetchExpectation = [self expectationWithDescription:@"fetch"];
    
    [DataCacheManager.sharedInstance fetchDataCachesWithIdentity:identity completionHandler:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
        XCTAssertTrue(dataCaches.count == 0);
        XCTAssertNil(error);
        [fetchExpectation fulfill];
    }];
    
    [self waitForExpectations:@[fetchExpectation] timeout:2.f];
}

@end
