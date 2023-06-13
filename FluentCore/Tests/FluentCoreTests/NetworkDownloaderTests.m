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
    
    __block NSData * _Nullable partialData;
    XCTestExpectation *downloadExpectation = [self expectationWithDescription:@"downloadExpectation"];
    
    NetworkDownloader *downloader = [NetworkDownloader new];
    NSDictionary *_userInfo = @{@"TEST": @3};
    [downloader downloadFromURL:NetworkDownloaderTests.testURL userInfo:_userInfo didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable __autoreleasing data, NSDictionary * _Nullable __autoreleasing userInfo, NSError * _Nullable __autoreleasing error) {
        XCTAssertEqualObjects(_userInfo, userInfo);
        XCTAssertNotNil(progress);
        XCTAssertNil(error);
        
        if (progress.isFinished) {
            partialData = [data retain];
            [downloadExpectation fulfill];
        }
    }];
    
    [downloader release];
    [self waitForExpectations:@[downloadExpectation] timeout:2.f];
    
    XCTAssertEqualObjects(normalData, partialData);
    [partialData release];
}

- (void)test_cachedData {
    [self test_uncachedData];
    
    XCTestExpectation *cacheExpectation = [self expectationWithDescription:@"cacheExpectation"];
    NetworkDownloader *downloader = [NetworkDownloader new];
    
    NSDictionary *_userInfo = @{@"TEST": @3};
    [downloader downloadFromURL:NetworkDownloaderTests.testURL userInfo:_userInfo didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable __autoreleasing data, NSDictionary * _Nullable __autoreleasing userInfo, NSError * _Nullable __autoreleasing error) {
        XCTAssertEqualObjects(_userInfo, userInfo);
        XCTAssertNil(progress);
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
