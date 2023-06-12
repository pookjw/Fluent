//
//  NetworkDownloader.h
//  
//
//  Created by Jinwoo Kim on 6/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NetworkDownloaderDidReceiveDataHandler)(NSProgress * _Nullable progress, NSData * _Nullable __autoreleasing data, BOOL isPartial, NSError * _Nullable __autoreleasing error);

@interface NetworkDownloader : NSObject
- (void)downloadFromURL:(NSURL *)url didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler;
- (void)downloadWithRequest:(NSURLRequest *)request didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler;
@end

NS_ASSUME_NONNULL_END
