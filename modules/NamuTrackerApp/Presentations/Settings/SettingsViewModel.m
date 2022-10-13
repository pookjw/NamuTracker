//
//  SettingsViewModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsViewModel.h"
#import "UICollectionViewDiffableDataSource+applySnapshotAndWait.h"
#import "NSDiffableDataSourceSnapshot+Sort.h"
#import "isMockMode.h"

typedef NSDiffableDataSourceSnapshot<SettingsSectionModel *, SettingsItemModel *> SettingsDataSourceSnapshot;

@interface NSDiffableDataSourceSnapshot (SortSettingsModels)
- (void)sortSettingsModels;
@end

@implementation NSDiffableDataSourceSnapshot (SortSettingsModels)

- (void)sortSettingsModels {
    [self sortSectionsUsingComparator:^NSComparisonResult(SettingsSectionModel * _Nonnull obj1, SettingsSectionModel * _Nonnull obj2) {
        if (obj1.type < obj2.type) {
            return NSOrderedAscending;
        } else if (obj1.type > obj2.type) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    [self sortItemsWithSectionIdentifiers:self.sectionIdentifiers
                          usingComparator:^NSComparisonResult(SettingsItemModel * _Nonnull obj1, SettingsItemModel * _Nonnull obj2) {
        if (obj1.type < obj2.type) {
            return NSOrderedAscending;
        } else if (obj1.type > obj2.type) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end

@interface SettingsViewModel ()
@property (strong) SettingsDataSource *dataSource;
@property (strong) NSOperationQueue *dataSourceQueue;
@end

@implementation SettingsViewModel

- (instancetype)initWithDataSource:(SettingsDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        
        [self configureDataSourceQueue];
        [self loadItems];
    }
    
    return self;
}

- (void)handleSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    [self.dataSourceQueue addOperationWithBlock:^{
        SettingsItemModel * _Nullable itemModel = [self.dataSource itemIdentifierForIndexPath:selectedIndexPath];
        if (itemModel == nil) return;
        
        [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameSettingsViewModelSelectedItemModel
                                                          object:self
                                                        userInfo:@{SettingsViewModelSelectedItemModelKey: itemModel}];
    }];
}

- (BOOL)canHandleIndexPath:(NSIndexPath *)indexPath {
    SettingsItemModel * _Nullable itemModel = [self.dataSource itemIdentifierForIndexPath:indexPath];
    
    switch (itemModel.type) {
        case SettingsItemModelTypeDecks:
            return YES;
        default:
            return NO;;
    }
}

- (void)configureDataSourceQueue {
    NSOperationQueue *dataSourceQueue = [NSOperationQueue new];
    dataSourceQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    dataSourceQueue.maxConcurrentOperationCount = 1;
    self.dataSourceQueue = dataSourceQueue;
}

- (void)loadItems {
    [self.dataSourceQueue addOperationWithBlock:^{
        SettingsDataSourceSnapshot *snapshot = [SettingsDataSourceSnapshot new];
        
        NSMutableArray<SettingsItemModel *> *noticesItemModels = [NSMutableArray<SettingsItemModel *> new];
#ifdef USERLAND_MODE
#if USERLAND_MODE
        [noticesItemModels addObject:[[SettingsItemModel alloc] initWithType:SettingsItemModelTypeUserlandNotice]];
#endif
#endif
        if (isMockMode()) {
            [noticesItemModels addObject:[[SettingsItemModel alloc] initWithType:SettingsItemModelTypeMockModeNotice]];
        }
        
        if (noticesItemModels.count > 0) {
            SettingsSectionModel *noticesSectionModel = [[SettingsSectionModel alloc] initWithType:SettingsSectionModelTypeNotices];
            [snapshot appendSectionsWithIdentifiers:@[noticesSectionModel]];
            [snapshot appendItemsWithIdentifiers:noticesItemModels intoSectionWithIdentifier:noticesSectionModel];
        }
        
        //
        
        SettingsSectionModel *itemsSectionModel = [[SettingsSectionModel alloc] initWithType:SettingsSectionModelTypeNavigations];
        [snapshot appendSectionsWithIdentifiers:@[itemsSectionModel]];
        [snapshot appendItemsWithIdentifiers:@[
            [[SettingsItemModel alloc] initWithType:SettingsItemModelTypeDecks]
        ]
                   intoSectionWithIdentifier:itemsSectionModel];
        
        //
    
        [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:NO completion:nil];
    }];
}

@end
