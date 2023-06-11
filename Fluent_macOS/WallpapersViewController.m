//
//  WallpapersViewController.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersViewController.h"
#import "WallpapersViewModel.h"

@interface WallpapersViewController ()
@property (retain) WallpapersViewModel *viewModel;
@end

@implementation WallpapersViewController

- (void)dealloc {
    [_viewModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewModel];
    [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)setupViewModel {
    WallpapersViewModel *viewModel = [[WallpapersViewModel alloc] initWithDataSource:nil];
    self.viewModel = viewModel;
    [viewModel release];
}

@end
