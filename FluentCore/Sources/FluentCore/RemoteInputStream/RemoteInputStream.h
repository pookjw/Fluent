//
//  RemoteInputStream.h
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteInputStream : NSInputStream
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)inputStreamWithData:(NSData *)data NS_UNAVAILABLE;
+ (instancetype)inputStreamWithFileAtPath:(NSString *)path NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)data NS_UNAVAILABLE;
- (instancetype)initWithFileAtPath:(NSString *)path NS_UNAVAILABLE;

+ (instancetype)inputStreamWithRequest:(NSURLRequest *)request;
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
