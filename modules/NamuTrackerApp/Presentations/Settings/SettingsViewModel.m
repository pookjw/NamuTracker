//
//  SettingsViewModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsViewModel.h"
#import "UICollectionViewDiffableDataSource+ApplySnapshotAndWait.h"
#import "NSDiffableDataSourceSnapshot+Sort.h"
#import "isMockMode.h"
#import "checkAvailability.h"
#import "AlternativeHSCardService.h"
#import "DataCacheService.h"
#import "CancellableBag.h"

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
@property (strong) AlternativeHSCardService *alternativeHSCardService;
@property (strong) DataCacheService *dataCacheService;
@property (strong) CancellableBag *cancellableBag;
@end

@implementation SettingsViewModel

- (instancetype)initWithDataSource:(SettingsDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        
        [self configureDataSourceQueue];
        [self configureAlternativeHSCardService];
        [self configureDataCacheService];
        [self configureCancellableBag];
        [self loadItems];
    }
    
    return self;
}

- (SettingsSectionModel *)sectionModelForIndexPath:(NSIndexPath *)indexPath {
    if (checkAvailability(@"15.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        return [self.dataSource sectionIdentifierForIndex:indexPath.section];
#pragma clang diagnostic pop
    } else {
        return self.dataSource.snapshot.sectionIdentifiers[indexPath.section];
    }
}

- (void)requestItemModelFromIndexPath:(NSIndexPath *)indexPath {
    [self.dataSourceQueue addOperationWithBlock:^{
        SettingsItemModel * _Nullable itemModel = [self.dataSource itemIdentifierForIndexPath:indexPath];
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
        case SettingsItemModelTypeHSAPIPreferences:
            return YES;
        case SettingsItemModelTypeReloadAlternativeHSCards:
            return YES;
        case SettingsItemModelTypeDeleteDataCaches:
            return YES;
        default:
            return NO;;
    }
}

- (void)reloadAlternativeHSCardsWithCompletion:(SettingsViewModelReloadAlternativeHSCardsCompletion)completion {
    CancellableObject *cancellable;
    
    cancellable = [self.alternativeHSCardService reloadAlternativeHSCardsWithCompletion:^(NSError * _Nullable error) {
        [self.cancellableBag removeCancellable:cancellable];
        completion(nil);
    }];
    [self.cancellableBag addCancellable:cancellable];
}

- (void)deleteAllDataCachesWithCompletion:(SettingsViewModelDeleteAllDataCachesCompletion)completion {
    [self.dataCacheService deleteAllDataCachesWithCompletion:completion];
}

- (void)configureDataSourceQueue {
    NSOperationQueue *dataSourceQueue = [NSOperationQueue new];
    dataSourceQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    dataSourceQueue.maxConcurrentOperationCount = 1;
    self.dataSourceQueue = dataSourceQueue;
}

- (void)configureAlternativeHSCardService {
    AlternativeHSCardService *alternativeHSCardService = AlternativeHSCardService.sharedInstance;
    self.alternativeHSCardService = alternativeHSCardService;
}

- (void)configureDataCacheService {
    DataCacheService *dataCacheService = DataCacheService.sharedInstance;
    self.dataCacheService = dataCacheService;
}

- (void)configureCancellableBag {
    CancellableBag *cancellableBag = [CancellableBag new];
    self.cancellableBag = cancellableBag;
}

- (void)loadItems {
    [self.dataSourceQueue addOperationWithBlock:^{
        SettingsDataSourceSnapshot *snapshot = [SettingsDataSourceSnapshot new];
        
        NSMutableArray<SettingsItemModel *> *noticesItemModels = [NSMutableArray<SettingsItemModel *> new];
#ifdef USERLAND_APP
#if USERLAND_APP
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
        
        SettingsSectionModel *generalSectionModel = [[SettingsSectionModel alloc] initWithType:SettingsSectionModelTypeGeneral];
        [snapshot appendSectionsWithIdentifiers:@[generalSectionModel]];
        [snapshot appendItemsWithIdentifiers:@[
            [[SettingsItemModel alloc] initWithType:SettingsItemModelTypeDecks],
            [[SettingsItemModel alloc] initWithType:SettingsItemModelTypeHSAPIPreferences],
            [[SettingsItemModel alloc] initWithType:SettingsItemModelTypeReloadAlternativeHSCards],
            [[SettingsItemModel alloc] initWithType:SettingsItemModelTypeDeleteDataCaches]
        ]
                   intoSectionWithIdentifier:generalSectionModel];
        
        //
    
        [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:NO completion:nil];
    }];
}

@end
