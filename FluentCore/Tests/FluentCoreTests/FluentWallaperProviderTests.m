#import <XCTest/XCTest.h>
@import FluentCore;

@interface FluentWallaperProviderTests : XCTestCase
@end

@implementation FluentWallaperProviderTests

- (void)test_start {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    FluentWallaperProvider *provider = [[FluentWallaperProvider alloc] initWithCompletionHandler:^(NSArray<FluentWallpaper *> * _Nullable fluentWallpapers, NSError * _Nullable error) {
        XCTAssertTrue(fluentWallpapers.count);
        
        [expectation fulfill];
    }];
    [provider start];
    
    [self waitForExpectations:@[expectation] timeout:100.f];
    [provider release];
}

@end
