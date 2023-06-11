#import <XCTest/XCTest.h>
@import FluentCore;

@interface KeyValueObservationTests : XCTestCase
@end

@implementation KeyValueObservationTests

- (void)test_basic {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    NSOperation *operation = [NSOperation new];
    
    [operation observeValueForKeyPath:@"isExecuting" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew changeHandler:^(id _Nonnull object, NSDictionary * _Nonnull changes) {
        if (((NSNumber *)changes[NSKeyValueChangeNewKey]).boolValue) {
            [expectation fulfill];
        }
    }];
    
    [queue addOperation:operation];
    [self waitForExpectations:@[expectation] timeout:2.f];
    [queue release];
}

- (void)test_invalidate {
    NSOperationQueue *queue = [NSOperationQueue new];
    NSOperation *operation = [NSOperation new];
    
    KeyValueObservation *observation = [operation observeValueForKeyPath:@"isExecuting" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew changeHandler:^(id _Nonnull object, NSDictionary * _Nonnull changes) {
        if (((NSNumber *)changes[NSKeyValueChangeNewKey]).boolValue) {
            XCTFail();
        }
    }];
    
    [observation invalidate];
    [queue addOperation:operation];
    [operation release];
    [NSThread sleepForTimeInterval:2.f];
    [queue release];
}

- (void)test_blockOperation {
    XCTestExpectation *isExecutingExpectation = [self expectationWithDescription:@"isExecutingExpectation"];
    XCTestExpectation *isCancelledExpectation = [self expectationWithDescription:@"isCancelledExpectation"];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    __block NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [blockOperation observeValueForKeyPath:@"isCancelled" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew changeHandler:^(id _Nonnull object, NSDictionary * _Nonnull changes) {
            if (((NSNumber *)changes[NSKeyValueChangeNewKey]).boolValue) {
                dispatch_semaphore_signal(semaphore);
                [isCancelledExpectation fulfill];
            }
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    }];
    
    [blockOperation observeValueForKeyPath:@"isExecuting" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew changeHandler:^(id _Nonnull object, NSDictionary * _Nonnull changes) {
        if (((NSNumber *)changes[NSKeyValueChangeNewKey]).boolValue) {
            [isExecutingExpectation fulfill];
        }
    }];
    
    [queue addOperation:blockOperation];
    [self waitForExpectations:@[isExecutingExpectation] timeout:2.f];
    [blockOperation cancel];
    [self waitForExpectations:@[isCancelledExpectation] timeout:2.f];
    [queue release];
}

@end
