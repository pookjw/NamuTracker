#import "TrackingListViewModel.h"
#import "HSLogService.h"
#import "CardService.h"
#import "AlternativeHSCard.h"
#import "checkAvailability.h"
#import "compareNullableValues.h"
#import "UICollectionViewDiffableDataSource+ApplySnapshotAndWait.h"
#import "NSDiffableDataSourceSnapshot+Sort.h"
#import "CancellableBag.h"

typedef NSDiffableDataSourceSnapshot<TrackingListSectionModel *, TrackingListItemModel *> TrackingListDataSourceSnapshot;

@interface NSDiffableDataSourceSnapshot (SortTrackingListModels)
- (void)sortTrackingListModels;
@end

@implementation NSDiffableDataSourceSnapshot (SortTrackingListModels)

- (void)sortTrackingListModels {
    [self sortSectionsUsingComparator:^NSComparisonResult(TrackingListSectionModel *obj1, TrackingListSectionModel *obj2) {
        if (obj1.type < obj2.type) {
            return NSOrderedAscending;
        } else if (obj1.type > obj2.type) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    //
    
    [self sortItemsWithSectionIdentifiers:self.sectionIdentifiers
                          usingComparator:^NSComparisonResult(TrackingListItemModel *obj1, TrackingListItemModel *obj2) {
        if ((obj1.type == TrackingListItemModelTypeHSCard) && (obj2.type == TrackingListItemModelTypeHSCard)) {
            return comparisonResultNullableValues(obj1.hsCard, obj2.hsCard, @selector(compare:));
        } else if ((obj1.type == TrackingListItemModelTypeHSCard) && (obj2.type == TrackingListItemModelTypeAlternativeHSCard)) {
            return NSOrderedAscending;
        } else if ((obj1.type == TrackingListItemModelTypeAlternativeHSCard) && (obj2.type == TrackingListItemModelTypeHSCard)) {
            return NSOrderedDescending;
        } else if ((obj1.type == TrackingListItemModelTypeAlternativeHSCard) && (obj2.type == TrackingListItemModelTypeAlternativeHSCard)) {
            return comparisonResultNullableValues(obj1.alternativeHSCard, obj2.alternativeHSCard, @selector(compare:));
        } else {
            return NSOrderedSame;
        }
    }];
}

@end

@interface TrackingListViewModel ()
@property (strong) TrackingListDataSource *dataSource;
@property (strong) NSOperationQueue *dataSourceQueue;
@property (strong) CancellableBag *cancellableBag;
@property (strong) HSLogService *hsLogService;
@property (strong) CardService *cardService;
@end

@implementation TrackingListViewModel

- (instancetype)initWithDataSource:(TrackingListDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;

        [self configureDataSourceQueue];
        [self configureCancellableBag];
        [self configureHSLogService];
        [self configureCardService];

        if (self.hsLogService.inGame) {
            [self loadItems];
        }

        [self bind];
    }

    return self;
}


- (void)dealloc {
    [self.dataSourceQueue cancelAllOperations];
}

- (void)configureDataSourceQueue {
    NSOperationQueue *dataSourceQueue = [NSOperationQueue new];
    dataSourceQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    dataSourceQueue.maxConcurrentOperationCount = 1;
    self.dataSourceQueue = dataSourceQueue;
}

- (void)configureCancellableBag {
    CancellableBag *cancellableBag = [CancellableBag new];
    self.cancellableBag = cancellableBag;
}

- (void)configureHSLogService {
    HSLogService *hsLogService = HSLogService.sharedInstance;
    self.hsLogService = hsLogService;
}

- (void)configureCardService {
    CardService *cardService = [CardService new];
    self.cardService = cardService;
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedDidStartTheGameNotification:) name:HSLogServiceNotificationNameDidStartTheGame object:self.hsLogService];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedDidEndTheGameNotification:) name:HSLogServiceNotificationNameDidEndTheGame object:self.hsLogService];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedDidChangeCardsNotification:) name:HSLogServiceNotificationNameDidChangeCards object:self.hsLogService];
}

- (void)loadItems {
    [self.dataSourceQueue addOperationWithBlock:^{
        [self.cancellableBag removeAllCancellables];

        __block NSArray<HSCard *> * _Nullable hsCards = nil;
        __block NSError * _Nullable error = nil;

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        CancellableObject *cancellable = [self.cardService hsCardsFromSelectedDeckWithCompletion:^(NSArray<HSCard *> * _Nullable _hsCards, NSError * _Nullable _error) {
            hsCards = _hsCards;
            error = _error;
            dispatch_semaphore_signal(semaphore);
        }];
        
        [self.cancellableBag addCancellable:cancellable];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [self.cancellableBag removeCancellable:cancellable];

        if (error) {
            NSLog(@"%@", error);
            return;
        }

        TrackingListDataSourceSnapshot *snapshot = [TrackingListDataSourceSnapshot new];

        TrackingListSectionModel *cardsSectionModel = [[TrackingListSectionModel alloc] initWithType:TrackingListSectionModelTypeCards];
        [snapshot appendSectionsWithIdentifiers:@[cardsSectionModel]];

        NSMutableSet<TrackingListItemModel *> *cardItemModels = [NSMutableSet<TrackingListItemModel *> new];
        [hsCards enumerateObjectsUsingBlock:^(HSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            __block TrackingListItemModel * _Nullable oldCardItemModel = nil;

            [cardItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, BOOL * _Nonnull stop2) {
                if ([obj1 isEqual:obj2.hsCard]) {
                    oldCardItemModel = obj2;
                    *stop2 = YES;
                }
            }];

            if (oldCardItemModel) {
                oldCardItemModel.hsCardCount = @(oldCardItemModel.hsCardCount.integerValue + 1);
            } else {
                TrackingListItemModel *cardItemModel = [[TrackingListItemModel alloc] initWithHSCard:obj1 hsCardCount:@1];
                [cardItemModels addObject:cardItemModel];
            }
        }];

        [snapshot appendItemsWithIdentifiers:cardItemModels.allObjects intoSectionWithIdentifier:cardsSectionModel];
        [snapshot sortTrackingListModels];

        if (checkAvailability(@"15.0")) {
            [self.dataSource applySnapshotUsingReloadDataAndWait:snapshot completion:nil];
        } else {
            [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:NO completion:nil];
        }  
    }];
}

- (void)unloadItems {
    [self.dataSourceQueue addOperationWithBlock:^{
        [self.cancellableBag removeAllCancellables];

        TrackingListDataSourceSnapshot *snapshot = [TrackingListDataSourceSnapshot new];

        if (checkAvailability(@"15.0")) {
            [self.dataSource applySnapshotUsingReloadDataAndWait:snapshot completion:nil];
        } else {
            [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:NO completion:nil];
        }
    }];
}

- (void)receivedDidStartTheGameNotification:(NSNotification *)notification {
    [self loadItems];
}

- (void)receivedDidEndTheGameNotification:(NSNotification *)notification {
    [self unloadItems];
}

- (void)receivedDidChangeCardsNotification:(NSNotification *)notification {
    NSDictionary * _Nullable userInfo = notification.userInfo;
    if (userInfo == nil) return;

    [self.dataSourceQueue addOperationWithBlock:^{
        TrackingListDataSourceSnapshot *snapshot = [self.dataSource.snapshot copy];

        __block TrackingListSectionModel * _Nullable cardsSectionModel = nil;
        [snapshot.sectionIdentifiers enumerateObjectsUsingBlock:^(TrackingListSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == TrackingListSectionModelTypeCards) {
                cardsSectionModel = obj;
                *stop = YES;
            }
        }];

        if (cardsSectionModel == nil) {
            NSLog(@"Cannot find cardsSectionModel.");
            return;
        }

        //

        NSArray<AlternativeHSCard *> *addedAlternativeHSCards = userInfo[HSLogServiceAddedAlternativeHSCardsUserInfoKey];
        NSArray<AlternativeHSCard *> *removedAlternativeHSCards = userInfo[HSLogServiceRemovedAlternativeHSCardsUserInfoKey];

        NSMutableSet<TrackingListItemModel *> *willReloadItemModels = [NSMutableSet<TrackingListItemModel *> new];
        NSMutableSet<TrackingListItemModel *> *unknownItemModels = [NSMutableSet<TrackingListItemModel *> new];

        [addedAlternativeHSCards enumerateObjectsUsingBlock:^(AlternativeHSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            __block BOOL foundExistingItem = NO;

            [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                BOOL isValid = NO;

                switch (obj2.type) {
                    case TrackingListItemModelTypeHSCard: {
                        if ([obj1.dbfId isEqualToNumber:obj2.hsCard.dbfId]) {
                            isValid = YES;
                        }
                        break;
                    }
                    case TrackingListItemModelTypeAlternativeHSCard: {
                        if (obj1.dbfId == obj2.alternativeHSCard.dbfId) {
                            isValid = YES;
                        }
                        break;
                    }
                    default: {
                        isValid = NO;
                        break;
                    }
                }

                if (!isValid) return;
                
                obj2.hsCardCount = @(obj2.hsCardCount.integerValue + 1);
                if (![willReloadItemModels containsObject:obj2]) {
                    [willReloadItemModels addObject:obj2];
                }

                foundExistingItem = YES;
                *stop2 = YES;
            }];

            if (!foundExistingItem) {
                __block BOOL foundUnknownExistingItem = NO;

                [unknownItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, BOOL * _Nonnull stop2) {
                    if ([obj1 isEqual:obj2.alternativeHSCard]) {
                        obj2.hsCardCount = @(obj2.hsCardCount.integerValue + 1);

                        foundUnknownExistingItem = YES;
                        *stop2 = YES;
                    }
                }];

                if (!foundUnknownExistingItem) {
                    TrackingListItemModel *itemModel = [[TrackingListItemModel alloc] initWithAlternativeHSCard:obj1 hsCardCount:@1];
                    [unknownItemModels addObject:itemModel];
                }
            }
        }];

        [removedAlternativeHSCards enumerateObjectsUsingBlock:^(AlternativeHSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                BOOL isValid = NO;

                switch (obj2.type) {
                    case TrackingListItemModelTypeHSCard: {
                        if ([obj1.dbfId isEqualToNumber:obj2.hsCard.dbfId]) {
                            isValid = YES;
                        }
                        break;
                    }
                    case TrackingListItemModelTypeAlternativeHSCard: {
                        if (obj1.dbfId == obj2.alternativeHSCard.dbfId) {
                            isValid = YES;
                        }
                        break;
                    }
                    default: {
                        isValid = NO;
                        break;
                    }
                }

                if (!isValid) return;

                obj2.hsCardCount = @(obj2.hsCardCount.integerValue - 1);

                if (![willReloadItemModels containsObject:obj2]) {
                    [willReloadItemModels addObject:obj2];
                }

                *stop2 = YES;
            }];
        }];

        //

        if (checkAvailability(@"15.0")) {
            [snapshot reconfigureItemsWithIdentifiers:willReloadItemModels.allObjects];
        } else {
            [snapshot reloadItemsWithIdentifiers:willReloadItemModels.allObjects];
        }

        [snapshot appendItemsWithIdentifiers:unknownItemModels.allObjects intoSectionWithIdentifier:cardsSectionModel];
        [snapshot sortTrackingListModels];

        //

        // download unknown cards (AlternativeHSCard) and apply them.
        [unknownItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj, BOOL * _Nonnull stop) {
            CancellableObject *cancellable;

            cancellable = [self.cardService hsCardWithAlternativeHSCard:obj.alternativeHSCard completion:^(HSCard * _Nullable hsCard, NSError * _Nullable error) {
                [self.dataSourceQueue addOperationWithBlock:^{
                    [self.cancellableBag removeCancellable:cancellable];

                    TrackingListDataSourceSnapshot *snapshot = [self.dataSource.snapshot copy];

                    __block TrackingListSectionModel * _Nullable cardsSectionModel = nil;
                    [snapshot.sectionIdentifiers enumerateObjectsUsingBlock:^(TrackingListSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.type == TrackingListSectionModelTypeCards) {
                            cardsSectionModel = obj;
                            *stop = YES;
                        }
                    }];

                    if (cardsSectionModel == nil) return;

                    //

                    __block TrackingListItemModel * _Nullable oldItemModel = nil;
                    [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.type != TrackingListItemModelTypeAlternativeHSCard) return;
                        if ([obj.alternativeHSCard.dbfId isEqualToNumber:hsCard.dbfId]) {
                            oldItemModel = obj;
                            *stop = YES;
                        }
                    }];

                    if (oldItemModel == nil) return;
                    [snapshot deleteItemsWithIdentifiers:@[oldItemModel]];

                    TrackingListItemModel *newItemModel = [[TrackingListItemModel alloc] initWithHSCard:hsCard hsCardCount:oldItemModel.hsCardCount];
                    [snapshot appendItemsWithIdentifiers:@[newItemModel] intoSectionWithIdentifier:cardsSectionModel];

                    [snapshot sortTrackingListModels];
                    
                    [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:YES completion:nil];
                }];
            }];

            [self.cancellableBag addCancellable:cancellable];
        }];

        //

        [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:YES completion:nil];
    }];
}

@end
