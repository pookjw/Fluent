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
@property (retain) NSVisualEffectView *blurView;
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (retain) WallpapersViewModel *viewModel;
@end

@implementation WallpapersViewController

- (void)dealloc {
    [_blurView release];
    [_scrollView release];
    [_collectionView release];
    [_viewModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBlurView];
    [self setupScrollView];
    [self setupCollectionView];
    [self setupViewModel];
    [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)setupBlurView {
    NSVisualEffectView *blurView = [NSVisualEffectView new];
    
    blurView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:blurView];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.blurView = blurView;
    [blurView release];
}

- (void)setupScrollView {
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.drawsBackground = NO;
    scrollView.contentView.drawsBackground = NO;
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView release];
}

- (void)setupCollectionView {
    NSCollectionViewCompositionalLayoutConfiguration *configuration = [NSCollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = NSCollectionViewScrollDirectionVertical;
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment> _Nonnull environment) {
        NSUInteger count = floorf(environment.container.contentSize.width / 300.f);
        if (count < 1) count = 1;
        
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f / count]
                                                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                           heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:9.f / (16.f * count)]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:count];
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:20.f];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        section.interGroupSpacing = 20.f;
        section.contentInsets = NSDirectionalEdgeInsetsMake(20.f, 20.f, 20.f, 20.f);
        
        return section;
    } configuration:configuration];
    
    [configuration release];
    
    NSCollectionView *collectionView = [NSCollectionView new];
    collectionView.backgroundColors = @[NSColor.clearColor];
    
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
