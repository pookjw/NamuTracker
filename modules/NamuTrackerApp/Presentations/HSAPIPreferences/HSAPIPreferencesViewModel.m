//
//  HSAPIPreferencesViewModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import "HSAPIPreferencesViewModel.h"
#import "HSAPIPreferenceService.h"
#import "UICollectionViewDiffableDataSource+applySnapshotAndWait.h"
#import "checkAvailability.h"
#import "NSDiffableDataSourceSnapshot+Sort.h"
#import "compareNullableValues.h"

typedef NSDiffableDataSourceSnapshot<HSAPIPreferencesSectionModel *, HSAPIPreferencesItemModel *> HSAPIPreferencesDataSourceSnapshot;

@interface NSDiffableDataSourceSnapshot (SortHSAPIPerferencesModels)
- (void)sortHSAPIPreferencesModels;
@end

@implementation NSDiffableDataSourceSnapshot (SortHSAPIPerferencesModels)

- (void)sortHSAPIPreferencesModels {
    [self sortSectionsUsingComparator:^NSComparisonResult(HSAPIPreferencesSectionModel * _Nonnull obj1, HSAPIPreferencesSectionModel * _Nonnull obj2) {
        if (obj1.type < obj2.type) {
            return NSOrderedAscending;
        } else if (obj1.type > obj2.type) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    [self sortItemsWithSectionIdentifiers:self.sectionIdentifiers
                          usingComparator:^NSComparisonResult(HSAPIPreferencesItemModel * _Nonnull obj1, HSAPIPreferencesItemModel * _Nonnull obj2) {
        if (obj1.type < obj2.type) {
            return NSOrderedAscending;
        } else if (obj1.type > obj2.type) {
            return NSOrderedDescending;
        } else {
            return comparisonResultNullableValues(obj1.text, obj2.text, @selector(compare:));
        }
    }];
}

@end

@interface HSAPIPreferencesViewModel ()
@property (strong) HSAPIPreferencesDataSource *dataSource;
@property (strong) NSOperationQueue *dataSourceQueue;
@property (strong) HSAPIPreferenceService *hsAPIPreferenceService;
@end

@implementation HSAPIPreferencesViewModel

- (instancetype)initWithDataSource:(HSAPIPreferencesDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        
        [self configureDataSourceQueue];
        [self configureHSAPIPreferenceService];
        [self loadItems];
        [self bind];
    }
    
    return self;
}

- (void)dealloc {
    [self.dataSourceQueue cancelAllOperations];
}

- (HSAPIPreferencesSectionModel *)sectionModelForIndexPath:(NSIndexPath *)indexPath {
    if (checkAvailability(@"15.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        return [self.dataSource sectionIdentifierForIndex:indexPath.section];
#pragma clang diagnostic pop
    } else {
        return self.dataSource.snapshot.sectionIdentifiers[indexPath.section];
    }
}

- (void)handleSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    [self.dataSourceQueue addOperationWithBlock:^{
        HSAPIPreferencesItemModel * _Nullable itemModel = [self.dataSource itemIdentifierForIndexPath:selectedIndexPath];
        if (itemModel == nil) return;
        
        switch (itemModel.type) {
            case HSAPIPreferencesItemModelTypeHSAPIRegionHost: {
                [self.hsAPIPreferenceService updateRegionHost:itemModel.hsAPIRegionHost.unsignedIntegerValue];
            }
            case HSAPIPreferencesItemModelTypeHSAPILocale: {
                [self.hsAPIPreferenceService updateLocale:itemModel.hsAPILocale];
            }
            default:
                break;
        }
    }];
}

- (void)configureDataSourceQueue {
    NSOperationQueue *dataSourceQueue = [NSOperationQueue new];
    dataSourceQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    dataSourceQueue.maxConcurrentOperationCount = 1;
    self.dataSourceQueue = dataSourceQueue;
}

- (void)configureHSAPIPreferenceService {
    HSAPIPreferenceService *hsAPIPreferenceService = HSAPIPreferenceService.sharedInstance;
    self.hsAPIPreferenceService = hsAPIPreferenceService;
}

- (void)loadItems {
    [self.hsAPIPreferenceService fetchRegionHostAndLocaleWithCompletion:^(HSAPIRegionHost regionHost, HSAPILocale  _Nonnull locale) {
        [self.dataSourceQueue addOperationWithBlock:^{
            HSAPIPreferencesDataSourceSnapshot *snapshot = [HSAPIPreferencesDataSourceSnapshot new];
            
            HSAPIPreferencesSectionModel *hsAPIRegionHostsSectionModel = [[HSAPIPreferencesSectionModel alloc] initWithType:HSAPIPreferencesSectionModelTypeHSAPIRegionHosts];
            HSAPIPreferencesSectionModel *hsAPILocalesSectionModel = [[HSAPIPreferencesSectionModel alloc] initWithType:HSAPIPreferencesSectionModelTypeHSAPILocales];
            
            [snapshot appendSectionsWithIdentifiers:@[hsAPIRegionHostsSectionModel, hsAPILocalesSectionModel]];
            
            [allHSAPIRegionHosts() enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                BOOL isSelected = (obj.unsignedIntegerValue == regionHost);
                HSAPIPreferencesItemModel *itemModel = [[HSAPIPreferencesItemModel alloc] initWithHSAPIRegionHost:obj.unsignedIntegerValue isSelected:isSelected];
                [snapshot appendItemsWithIdentifiers:@[itemModel] intoSectionWithIdentifier:hsAPIRegionHostsSectionModel];
            }];
            
            [allHSAPILocales() enumerateObjectsUsingBlock:^(HSAPILocale  _Nonnull obj, BOOL * _Nonnull stop) {
                BOOL isSelected = [obj isEqualToString:locale];
                HSAPIPreferencesItemModel *itemModel = [[HSAPIPreferencesItemModel alloc] initWithHSAPILocale:obj isSelected:isSelected];
                [snapshot appendItemsWithIdentifiers:@[itemModel] intoSectionWithIdentifier:hsAPILocalesSectionModel];
            }];
            
            [snapshot sortHSAPIPreferencesModels];
            
            [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:NO completion:^{
                
            }];
        }];
    }];
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedHSAPIPreferenceServiceDidSaveNotification:)
                                               name:NSNotificationNameHSAPIPreferenceServiceDidSave
                                             object:self.hsAPIPreferenceService];
}

- (void)receivedHSAPIPreferenceServiceDidSaveNotification:(NSNotification *)notification {
    [self.hsAPIPreferenceService fetchRegionHostAndLocaleWithCompletion:^(HSAPIRegionHost regionHost, HSAPILocale  _Nonnull locale) {
        [self.dataSourceQueue addOperationWithBlock:^{
            HSAPIPreferencesDataSourceSnapshot *snapshot = [self.dataSource.snapshot copy];
            
            HSAPIPreferencesSectionModel * _Nullable __block hsAPIRegionHostsSectionModel = nil;
            HSAPIPreferencesSectionModel * _Nullable __block hsAPILocalesSectionModel = nil;
            
            [snapshot.sectionIdentifiers enumerateObjectsUsingBlock:^(HSAPIPreferencesSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                switch (obj.type) {
                    case HSAPIPreferencesSectionModelTypeHSAPIRegionHosts:
                        hsAPIRegionHostsSectionModel = obj;
                        break;
                    case HSAPIPreferencesSectionModelTypeHSAPILocales:
                        hsAPILocalesSectionModel = obj;
                        return;
                    default:
                        break;
                }
                if ((hsAPIRegionHostsSectionModel != nil) && (hsAPILocalesSectionModel != nil)) {
                    *stop = YES;
                }
            }];
            
            //
            
            NSMutableArray<HSAPIPreferencesItemModel *> *toBeReloadedItemModels = [NSMutableArray<HSAPIPreferencesItemModel *> new];
            
            if (hsAPIRegionHostsSectionModel) {
                [[snapshot itemIdentifiersInSectionWithIdentifier:hsAPIRegionHostsSectionModel] enumerateObjectsUsingBlock:^(HSAPIPreferencesItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.isSelected) {
                        if (regionHost != obj.hsAPIRegionHost.unsignedIntegerValue) {
                            obj.selected = NO;
                            [toBeReloadedItemModels addObject:obj];
                        }
                    } else {
                        if (regionHost == obj.hsAPIRegionHost.unsignedIntegerValue) {
                            obj.selected = YES;
                            [toBeReloadedItemModels addObject:obj];
                        }
                    }
                }];
            }
            
            if (hsAPILocalesSectionModel) {
                [[snapshot itemIdentifiersInSectionWithIdentifier:hsAPILocalesSectionModel] enumerateObjectsUsingBlock:^(HSAPIPreferencesItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.isSelected) {
                        if (![locale isEqualToString:obj.hsAPILocale]) {
                            obj.selected = NO;
                            [toBeReloadedItemModels addObject:obj];
                        }
                    } else {
                        if ([locale isEqualToString:obj.hsAPILocale]) {
                            obj.selected = YES;
                            [toBeReloadedItemModels addObject:obj];
                        }
                    }
                }];
            }
            
            //
            
            if (checkAvailability(@"15.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
                [snapshot reconfigureItemsWithIdentifiers:toBeReloadedItemModels];
#pragma clang diagnostic pop
            } else {
                [snapshot reloadItemsWithIdentifiers:toBeReloadedItemModels];
            }
            
            [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:YES completion:^{
                
            }];
        }];
    }];
}

@end
