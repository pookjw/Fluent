//
//  WallpapersViewModel.h
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <AppKit/AppKit.h>
#import "WallpapersSectionModel.h"
#import "WallpapersItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSCollectionViewDiffableDataSource<WallpapersSectionModel *, WallpapersItemModel *> WallpapersDataSource;
typedef NSDiffableDataSourceSnapshot<WallpapersSectionModel *, WallpapersItemModel *> WallpapersSnapshot;

@interface WallpapersViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(WallpapersDataSource *)dataSource;
- (void)loadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable __autoreleasing error))completionHandler;
@end

NS_ASSUME_NONNULL_END
