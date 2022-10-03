#import "TrackingListViewModel.h"
#import "HSLogService.h"
#import "CardService.h"
#import "AlternativeHSCard.h"
#import <checkAvailability.h>

@interface TrackingListViewModel ()
@property (strong) TrackingListDataSource *dataSource;
@property (strong) NSOperationQueue *queue;
@property (strong) HSLogService *hsLogService;
@property (strong) CardService *cardService;
@end

@implementation TrackingListViewModel

- (instancetype)initWithDataSource:(TrackingListDataSource *)dataSource {
    if (self = [self init]) {
        self.dataSource = dataSource;

        [self configureQueue];
        [self configureHSLogService];
        [self configureCardService];

        if (self.hsLogService.inGame) {
            [self loadItems];
        }

        [self bind];
    }

    return self;
}

- (void)configureQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
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
    [self.queue addOperationWithBlock:^{
        [self.cardService hsCardsFromSelectedDeckWithCompletionHandler:^(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error) {
            NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];

            TrackingListSectionModel *cardsSectionModel = [[TrackingListSectionModel alloc] initCardsSection];
            [snapshot appendSectionsWithIdentifiers:@[cardsSectionModel]];

            NSMutableArray<TrackingListItemModel *> *cardItemModels = [NSMutableArray<TrackingListItemModel *> new];
            [hsCards enumerateObjectsUsingBlock:^(HSCard * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
                TrackingListItemModel * _Nullable __block oldCardItemModel = nil;

                [cardItemModels enumerateObjectsUsingBlock:^(TrackingListItemModel * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                    if ((obj2.hsCard) && ([obj2.hsCard isEqual:obj1])) {
                        oldCardItemModel = obj2;
                        *stop2 = YES;
                    }
                }];

                if (oldCardItemModel) {
                    oldCardItemModel.hsCardCount = @(oldCardItemModel.hsCardCount.unsignedIntegerValue + 1);
                } else {
                    TrackingListItemModel *cardItemModel = [[TrackingListItemModel alloc] initWithHSCard:obj1 hsCardCount:@1];
                    [cardItemModels addObject:cardItemModel];
                }
            }];

            [snapshot appendItemsWithIdentifiers:cardItemModels intoSectionWithIdentifier:cardsSectionModel];

            if (checkAvailability(@"15.0")) {
                [self.dataSource applySnapshotUsingReloadData:snapshot completion:nil];
            } else {
                [self.dataSource applySnapshot:snapshot animatingDifferences:NO completion:nil];
            }
        }];   
    }];
}

- (void)unloadItems {
    [self.queue addOperationWithBlock:^{
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

    [self.queue addOperationWithBlock:^{
        NSArray<AlternativeHSCard *> *addedAlternativeHSCards = userInfo[HSLogServiceAddedAlternativeHSCardsUserInfoKey];
        NSArray<AlternativeHSCard *> *removedAlternativeHSCards = userInfo[HSLogServiceRemovedAlternativeHSCardsUserInfoKey];
    }];
}

@end
