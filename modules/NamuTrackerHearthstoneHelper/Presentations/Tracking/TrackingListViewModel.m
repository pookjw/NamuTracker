#import "TrackingListViewModel.h"
#import "HSLogService.h"
#import "CardService.h"
#import "AlternativeHSCard.h"
#import <checkAvailability.h>
#import <compareNullableValues.h>
#import "NSDiffableDataSourceSnapshot+Sort.h"
#import "CancellableBag.h"

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
        if ((obj1.type == TrackingListItemModelTypeCard) && (obj2.type == TrackingListItemModelTypeCard)) {
            HSCard * _Nullable obj1_HSCard = obj1.hsCard;
            HSCard * _Nullable obj2_HSCard = obj2.hsCard;
            AlternativeHSCard * _Nullable obj1_AlternativeHSCard = obj1.alternativeHSCard;
            AlternativeHSCard * _Nullable obj2_AlternativeHSCard = obj2.alternativeHSCard;

            if ((obj1_HSCard != nil) && (obj2_HSCard != nil)) {
                return [obj1_HSCard compare:obj2_HSCard];
            } else if ((obj1_AlternativeHSCard != nil) && (obj2_AlternativeHSCard != nil)) {
                return [obj1_AlternativeHSCard compare:obj2_AlternativeHSCard];
            } else if ((obj1_HSCard != nil) && (obj2_AlternativeHSCard != nil)) {
                return NSOrderedDescending;
            } else if ((obj1_AlternativeHSCard == nil) && (obj2_HSCard != nil)) {
                return NSOrderedAscending;
            } else {
                NSLog(@"Unexpected!");
                return compareNullableValues(obj1_HSCard, obj2_HSCard, @selector(isEqual:));
            }
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
    if (self = [self init]) {
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

        NSArray<HSCard *> * _Nullable __block hsCards = nil;
        NSError * _Nullable __block error = nil;

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        CancellableObject *cancellable = [self.cardService hsCardsFromSelectedDeckWithCompletionHandler:^(NSArray<HSCard *> * _Nullable _hsCards, NSError * _Nullable _error) {
            hsCards = _hsCards;
            error = _error;
            dispatch_semaphore_signal(semaphore);
        }];
        
        [self.cancellableBag addCancellable:cancellable];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [self.cancellableBag removeCancellable:cancellable];

        if (error) return;

        NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];

        TrackingListSectionModel *cardsSectionModel = [[TrackingListSectionModel alloc] initCardsSection];
        [snapshot appendSectionsWithIdentifiers:@[cardsSectionModel]];

        NSMutableSet<TrackingListItemModel *> *cardItemModels = [NSMutableSet<TrackingListItemModel *> new];
        [hsCards enumerateObjectsUsingBlock:^(HSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            TrackingListItemModel * _Nullable __block oldCardItemModel = nil;

            [cardItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, BOOL * _Nonnull stop2) {
                if ([obj1 isEqual:obj2.hsCard]) {
                    oldCardItemModel = obj2;
                    *stop2 = YES;
                }
            }];

            if (oldCardItemModel) {
                oldCardItemModel.hsCardCount = @(oldCardItemModel.hsCardCount.unsignedIntegerValue + 1);
            } else {
                TrackingListItemModel *cardItemModel = [[TrackingListItemModel alloc] initWithHSCard:obj1 alternativeHSCard:nil hsCardCount:@1];
                [cardItemModels addObject:cardItemModel];
            }
        }];

        [snapshot appendItemsWithIdentifiers:cardItemModels.allObjects intoSectionWithIdentifier:cardsSectionModel];
        [snapshot sortTrackingListModels];

        if (checkAvailability(@"15.0")) {
            [self.dataSource applySnapshotUsingReloadData:snapshot completion:nil];
        } else {
            [self.dataSource applySnapshot:snapshot animatingDifferences:NO completion:nil];
        }  
    }];
}

- (void)unloadItems {
    [self.dataSourceQueue addOperationWithBlock:^{
        [self.cancellableBag removeAllCancellables];

        NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];

        if (checkAvailability(@"15.0")) {
            [self.dataSource applySnapshotUsingReloadData:snapshot completion:nil];
        } else {
            [self.dataSource applySnapshot:snapshot animatingDifferences:NO completion:nil];
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
        NSDiffableDataSourceSnapshot *snapshot = [self.dataSource.snapshot copy];

        TrackingListSectionModel * _Nullable __block cardsSectionModel = nil;
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
            BOOL __block foundExistingItem = NO;

            [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                if (obj2.type != TrackingListItemModelTypeCard) return;

                if ((obj1.dbfId == obj2.hsCard.dbfId.unsignedIntegerValue) || (obj1.dbfId == obj2.alternativeHSCard.dbfId)) {
                    obj2.hsCardCount = @(obj2.hsCardCount.unsignedIntegerValue + 1);
                    if (![willReloadItemModels containsObject:obj2]) {
                        [willReloadItemModels addObject:obj2];
                    }

                    foundExistingItem = YES;
                    *stop2 = YES;
                }
            }];

            if (!foundExistingItem) {
                BOOL __block foundUnknownExistingItem = NO;

                [unknownItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, BOOL * _Nonnull stop2) {
                    if ([obj1 isEqual:obj2.alternativeHSCard]) {
                        obj2.hsCardCount = @(obj2.hsCardCount.unsignedIntegerValue + 1);

                        foundUnknownExistingItem = YES;
                        *stop2 = YES;
                    }
                }];

                if (!foundUnknownExistingItem) {
                    TrackingListItemModel *itemModel = [[TrackingListItemModel alloc] initWithHSCard:nil alternativeHSCard:obj1 hsCardCount:@1];
                    [unknownItemModels addObject:itemModel];
                }
            }
        }];

        [removedAlternativeHSCards enumerateObjectsUsingBlock:^(AlternativeHSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                if (obj2.type != TrackingListItemModelTypeCard) return;
                if (obj1.dbfId != obj2.hsCard.dbfId.unsignedIntegerValue) return;

                obj2.hsCardCount = @(obj2.hsCardCount.unsignedIntegerValue - 1);

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

            cancellable = [self.cardService hsCardWithAlternativeHSCard:obj.alternativeHSCard completionHandler:^(HSCard * _Nullable hsCard, NSError * _Nullable error) {
                [self.dataSourceQueue addOperationWithBlock:^{
                    [self.cancellableBag removeCancellable:cancellable];

                    NSDiffableDataSourceSnapshot *snapshot = [self.dataSource.snapshot copy];

                    TrackingListSectionModel * _Nullable __block cardsSectionModel = nil;
                    [snapshot.sectionIdentifiers enumerateObjectsUsingBlock:^(TrackingListSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.type == TrackingListSectionModelTypeCards) {
                            cardsSectionModel = obj;
                            *stop = YES;
                        }
                    }];

                    if (cardsSectionModel == nil) return;

                    //

                    TrackingListItemModel * _Nullable __block oldItemModel = nil;
                    [snapshot.itemIdentifiers enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.type != TrackingListSectionModelTypeCards) return;
                        if (obj.alternativeHSCard.dbfId == hsCard.dbfId.unsignedIntegerValue) {
                            oldItemModel = obj;
                            *stop = YES;
                        }
                    }];

                    if (oldItemModel == nil) return;
                    [snapshot deleteItemsWithIdentifiers:@[oldItemModel]];

                    TrackingListItemModel *newItemModel = [[TrackingListItemModel alloc] initWithHSCard:hsCard alternativeHSCard:nil hsCardCount:oldItemModel.hsCardCount];
                    [snapshot appendItemsWithIdentifiers:@[newItemModel] intoSectionWithIdentifier:cardsSectionModel];

                    [snapshot sortTrackingListModels];
                    
                    [self.dataSource applySnapshot:snapshot animatingDifferences:YES completion:nil];
                }];
            }];

            [self.cancellableBag addCancellable:cancellable];
        }];

        //

        [self.dataSource applySnapshot:snapshot animatingDifferences:YES completion:nil];
    }];
}

@end
