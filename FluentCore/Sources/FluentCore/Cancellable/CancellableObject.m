//
//  CancellableObject.m
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "CancellableObject.h"
#import <objc/objc-sync.h>

@interface CancellableObject ()
@property (copy, nullable) void (^cancellationHandler)(void);
@end

@implementation CancellableObject

@synthesize isCancelled = _isCancelled;

- (instancetype)initWithCancellationHandler:(void (^)(void))cancellationHandler {
    if (self = [super init]) {
        self.cancellationHandler = cancellationHandler;
    }
    
    return self;
}

- (void)dealloc {
    [_cancellationHandler release];
    [super dealloc];
}

- (BOOL)isCancelled {
    BOOL isCancelled;
    objc_sync_enter(self);
    isCancelled = _isCancelled;
    objc_sync_exit(self);
    return isCancelled;
}

- (void)setIsCancelled:(BOOL)isCancelled {
    objc_sync_enter(self);
    _isCancelled = isCancelled;
    objc_sync_exit(self);
}

- (void)cancel {
    objc_sync_enter(self);
    if (_isCancelled) return;
    _isCancelled = YES;
    self.cancellationHandler();
    self.cancellationHandler = nil;
    objc_sync_exit(self);
}

@end
