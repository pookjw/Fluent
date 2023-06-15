//
//  RemoteInputStream.m
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "RemoteInputStream.h"
#import <objc/objc-sync.h>

@interface RemoteInputStream () <NSURLSessionDataDelegate>
@property (retain) NSURLSessionDataTask *sessionDataTask;
@property (retain) NSMutableArray<NSData *> *bufferData;
@property (retain, nullable) dispatch_semaphore_t semaphore;
@end

@implementation RemoteInputStream

+ (instancetype)inputStreamWithRequest:(NSURLRequest *)request {
    return [[[self.class alloc] initWithRequest:request] autorelease];
}

- (instancetype)initWithURL:(NSURL *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self = [self initWithRequest:request];
    [request release];
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [super initWithURL:request.URL]) {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request];
        self.sessionDataTask = sessionDataTask;
        
        NSMutableArray<NSData *> *bufferData = [NSMutableArray<NSData *> new];
        self.bufferData = bufferData;
        [bufferData release];
    }
    
    return self;
}

- (void)dealloc {
    [_sessionDataTask cancel];
    [_sessionDataTask release];
    [_bufferData release];
    
    if (_semaphore) {
        dispatch_release(_semaphore);
    }
    
    [super dealloc];
}

- (void)open {
    self.sessionDataTask.delegate = self;
    [self.sessionDataTask resume];
}

- (void)close {
    self.sessionDataTask.delegate = self;
    [self.sessionDataTask suspend];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    objc_sync_enter(self);
    
    if (self.bufferData.count == 0) {
        if (self.sessionDataTask.state == NSURLSessionTaskStateRunning) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            self.semaphore = semaphore;
            
            objc_sync_exit(self);
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            objc_sync_enter(self);
            
            self.semaphore = nil;
            dispatch_release(semaphore);
            
            if (self.bufferData.count == 0) {
                objc_sync_exit(self);
                return 0;
            }
        } else {
            objc_sync_exit(self);
            return 0;
        }
    }
    
    NSMutableData *result = [NSMutableData new];
    NSUInteger remaining = len;
    
    while (YES) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        BOOL shouldBreak;
        
        if (remaining < self.bufferData[0].length) {
            NSData *data1 = [self.bufferData[0] subdataWithRange:NSMakeRange(0, remaining)];
            NSData *data2 = [self.bufferData[0] subdataWithRange:NSMakeRange(remaining, self.bufferData[0].length - remaining)];
            
            [result appendData:data1];
            [self.bufferData replaceObjectAtIndex:0 withObject:data2];
            remaining = 0;
            shouldBreak = YES;
        } else {
            [result appendData:self.bufferData[0]];
            remaining -= self.bufferData[0].length;
            [self.bufferData removeObjectAtIndex:0];
            
            if (self.bufferData.count == 0) {
                shouldBreak = YES;
            } else {
                shouldBreak = NO;
            }
        }
        
        [pool release];
        
        if (remaining == 0) {
            shouldBreak = YES;
        }
        
        if (shouldBreak) {
            break;
        }
    }
    
    objc_sync_exit(self);
    
    NSUInteger length = result.length;
    
    memcpy(buffer, result.bytes, length);
    [result release];
    
    return length;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    objc_sync_enter(self);
    [self.bufferData addObject:data];
    
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
    
    objc_sync_exit(self);
}

@end
