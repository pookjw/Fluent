//
//  NetworkDownloaderTests.m
//  
//
//  Created by Jinwoo Kim on 6/12/23.
//

#import <XCTest/XCTestCase.h>
@import FluentCore;

@interface NetworkDownloaderTests : XCTestCase
@property (class, readonly) NSURL *testURL;
@end

@implementation NetworkDownloaderTests

+ (NSURL *)testURL {
    return [NSURL URLWithString:@"https://fastly.picsum.photos/id/11/2500/1667.jpg?hmac=xxjFJtAPgshYkysU_aqx2sZir-kIOjNR9vx0te7GycQ"];
}

- (void)test_uncachedData {
    XCTestExpectation *deleteAllExpectation = [self expectationWithDescription:@"deleteAllExpectation"];
    
    [DataCacheManager.sharedInstance destoryWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [deleteAllExpectation fulfill];
    }];
    
    [self waitForExpectations:@[deleteAllExpectation] timeout:2.f];
    
    NSData *normalData = [NSData dataWithContentsOfURL:NetworkDownloaderTests.testURL];
    
    NSMutableData *partialData = [NSMutableData new];
    XCTestExpectation *downloadExpectation = [self expectationWithDescription:@"downloadExpectation"];
    
    NetworkDownloader *downloader = [NetworkDownloader new];
    
    [downloader downloadFromURL:NetworkDownloaderTests.testURL didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable data, BOOL isPartial, NSError * _Nullable error) {
        XCTAssertTrue(isPartial);
        XCTAssertNil(error);
        
        if (data) {
            [partialData appendData:data];
        }
        
        if (progress.isFinished) {
            [downloadExpectation fulfill];
        }
    }];
    
    [downloader release];
    [self waitForExpectations:@[downloadExpectation] timeout:2.f];
    
    XCTAssertEqualObjects(normalData, partialData);
}

- (void)test_cachedData {
    [self test_uncachedData];
    
    XCTestExpectation *cacheExpectation = [self expectationWithDescription:@"cacheExpectation"];
    NetworkDownloader *downloader = [NetworkDownloader new];
    
    [downloader downloadFromURL:NetworkDownloaderTests.testURL didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable data, BOOL isPartial, NSError * _Nullable error) {
        XCTAssertFalse(isPartial);
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        NSData *normalData = [NSData dataWithContentsOfURL:NetworkDownloaderTests.testURL];
        XCTAssertEqualObjects(normalData, data);
        [cacheExpectation fulfill];
    }];
    
    [downloader release];
    [self waitForExpectations:@[cacheExpectation] timeout:2.f];
}

@end
