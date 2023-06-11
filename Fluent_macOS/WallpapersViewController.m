//
//  WallpapersViewController.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersViewController.h"
#import "WallpapersViewModel.h"
#import "WallpapersFluentWallpaperCollectionViewItem.h"

@interface WallpapersViewController ()
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (retain) WallpapersViewModel *viewModel;
@end

@implementation WallpapersViewController

- (void)dealloc {
    [_scrollView release];
    [_collectionView release];
    [_viewModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupCollectionView];
    [self setupViewModel];
    [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)setupScrollView {
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.drawsBackground = NO;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView release];
}

- (void)setupCollectionView {
    NSCollectionViewCompositionalLayoutConfiguration *configuration = [NSCollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = NSCollectionViewScrollDirectionVertical;
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment> _Nonnull environment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f / 3.f]
                                                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                           heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f / 3.f]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:3];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        return section;
    } configuration:configuration];
    
    [configuration release];
    
    NSCollectionView *collectionView = [NSCollectionView new];
    collectionView.collectionViewLayout = collectionViewLayout;
    [collectionViewLayout release];
    [collectionView registerClass:WallpapersFluentWallpaperCollectionViewItem.class forItemWithIdentifier:NSUserInterfaceItemIdentifierWallpapersFluentWallpaperCollectionViewItem];
    
    self.scrollView.documentView = collectionView;
    self.collectionView = collectionView;
    [collectionView release];
}

- (void)setupViewModel {
    WallpapersDataSource *dataSource = [self createDataSource];
    WallpapersViewModel *viewModel = [[WallpapersViewModel alloc] initWithDataSource:dataSource];
    self.viewModel = viewModel;
    [viewModel release];
}

- (WallpapersDataSource *)createDataSource {
    WallpapersDataSource *dataSource = [[WallpapersDataSource alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, WallpapersItemModel * _Nonnull itemModel) {
        WallpapersFluentWallpaperCollectionViewItem *item = [collectionView makeItemWithIdentifier:NSUserInterfaceItemIdentifierWallpapersFluentWallpaperCollectionViewItem forIndexPath:indexPath];
        [item setupWithFluentWallpaper:itemModel.fluentWallpaper];
        return item;
    }];
    
    return [dataSource autorelease];
}

@end
