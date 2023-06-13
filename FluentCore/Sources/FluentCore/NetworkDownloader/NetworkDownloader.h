//
//  NetworkDownloader.h
//  
//
//  Created by Jinwoo Kim on 6/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NetworkDownloaderDidReceiveDataHandler)(NSProgress * _Nullable progress, NSData * _Nullable __autoreleasing data, NSDictionary * _Nullable __autoreleasing userInfo, NSError * _Nullable __autoreleasing error);

@interface NetworkDownloader : NSObject
- (void)downloadFromURL:(NSURL *)url userInfo:(NSDictionary * _Nullable)userInfo didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler;
- (void)downloadWithRequest:(NSURLRequest *)request userInfo:(NSDictionary * _Nullable)userInfo didReceiveDataHandler:(NetworkDownloaderDidReceiveDataHandler)didReceiveDataHandler;
@end

NS_ASSUME_NONNULL_END
