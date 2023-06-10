//
//  RemoteInputStreamTests.m
//  
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <XCTest/XCTestCase.h>
#import <AppKit/AppKit.h>
@import FluentCore;

@interface RemoteInputStreamTests : XCTestCase
@end

@implementation RemoteInputStreamTests

- (void)test_read {
    NSURL *testURL = [NSURL URLWithString:@"https://fastly.picsum.photos/id/11/2500/1667.jpg?hmac=xxjFJtAPgshYkysU_aqx2sZir-kIOjNR9vx0te7GycQ"];
    NSData *normalData = [NSData dataWithContentsOfURL:testURL];
    
    RemoteInputStream *inputStream = [RemoteInputStream inputStreamWithURL:testURL];
    [inputStream open];
    
    NSUInteger maxLength = 16;
    uint8_t *buffer = malloc(sizeof(uint8_t) * maxLength);
    NSUInteger len = [inputStream read:buffer maxLength:maxLength];
    NSMutableData *streamingData = [NSMutableData new];
    
    while (len) {
        [streamingData appendBytes:buffer length:len];
        len = [inputStream read:buffer maxLength:maxLength];
    }
    
    free(buffer);
    
    XCTAssertTrue([normalData isEqualToData:streamingData]);
    
    [streamingData release];
}

@end
