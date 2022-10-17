//
//  DecksViewModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import "DecksViewModel.h"
#import "LocalDeckService.h"
#import "HSAPIService.h"
#import "identifiers.h"
#import "CancellableBag.h"
#import "LocalizableService.h"
#import "UICollectionViewDiffableDataSource+applySnapshotAndWait.h"

@interface DecksViewModel () <NSFetchedResultsControllerDelegate>
@property (strong) DecksDataSource *dataSource;
@property (strong) NSOperationQueue *dataSourceQueue;
@property (strong) LocalDeckService *localDeckService;
@property (strong) HSAPIService *hsAPIService;
@property (strong) NSFetchedResultsController *fetchedResultsController;
@property (strong) NSOperationQueue *backgroundQueue;
@property (strong) CancellableBag *cancellableBag;
@end

@implementation DecksViewModel

- (instancetype)initWithDataSource:(DecksDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        [self configureDataSourceQueue];
        [self configureLocalDeckService];
        [self configureHSAPIService];
        [self configureFetchedResultsController];
        [self configureBackgroundQueue];
        [self configureCancellableBag];
        [self bind];
    }
    
    return self;
}

- (void)dealloc {
    [self.dataSourceQueue cancelAllOperations];
}

- (LocalDeck * _Nullable)localDeckFromIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)parseClipboardForDeckCodeWithCompletion:(DecksViewModelParseClipboardCompletion)completion {
    [self.backgroundQueue addOperationWithBlock:^{
        NSString *text = UIPasteboard.generalPasteboard.string;
        
        NSString * _Nullable __block name = nil;
        NSString * _Nullable __block deckCode = nil;
        
        [[text componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"### "]) {
                name = [obj componentsSeparatedByString:@"### "].lastObject;
            } else if ([obj hasPrefix:@"AA"]) {
                deckCode = obj;
            }
            
            if ((text) && (deckCode)) {
                *stop = YES;
            }
        }];
        
        completion(name, deckCode);
    }];
}

- (void)createLocalDeckFromDeckCode:(NSString *)deckCode name:(NSString *)name {
    __weak typeof(self) weakSelf = self;
    
    [self.backgroundQueue addOperationWithBlock:^{
        CancellableObject *cancellable;
        
        cancellable = [weakSelf.hsAPIService hsDeckFromDeckCode:deckCode completion:^(HSDeck * _Nullable hsDeck, NSError * _Nullable error) {
            [weakSelf.cancellableBag removeCancellable:cancellable];
            
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            
            [weakSelf.localDeckService fetchLocalDecksCountWithCompletion:^(NSUInteger count, NSError * _Nullable error) {
                [weakSelf.localDeckService createLocalDeckWithCompletion:^(LocalDeck * _Nullable localDeck, NSError * _Nullable error) {
                    [localDeck synchronizeWithHSDeck:hsDeck];
                    
                    NSString *_name;
                    if ((name) && (name.length > 0)) {
                        _name = name;
                    } else {
                        _name = [LocalizableService localizableForKey:LocalizableKeyUntitledDeck];
                    }
                    localDeck.name = _name;
                    
                    localDeck.timestamp = [NSDate new];
                    localDeck.selected = @(count == 0);
                    [weakSelf.localDeckService saveChanges];
                }];
            }];
        }];
        
        [weakSelf.cancellableBag addCancellable:cancellable];
    }];
}

- (void)setSelectedWithIndexPath:(NSIndexPath *)indexPath {
    [self.backgroundQueue addOperationWithBlock:^{
        LocalDeck *selectedLocalDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.localDeckService fetchLocalDecksWithCompletion:^(NSArray<LocalDeck *> * _Nullable localDecks, NSError * _Nullable error) {
            [localDecks enumerateObjectsUsingBlock:^(LocalDeck * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.selected = @([obj isEqual:selectedLocalDeck]);
            }];
            
            [self.localDeckService saveChanges];
        }];
    }];
}

- (void)configureDataSourceQueue {
    NSOperationQueue *dataSourceQueue = [NSOperationQueue new];
    dataSourceQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    dataSourceQueue.maxConcurrentOperationCount = 1;
    self.dataSourceQueue = dataSourceQueue;
}

- (void)configureLocalDeckService {
    LocalDeckService *localDeckService = LocalDeckService.sharedInstance;
    self.localDeckService = localDeckService;
}

- (void)configureHSAPIService {
    HSAPIService *hsAPIService = [HSAPIService new];
    self.hsAPIService = hsAPIService;
}

- (void)configureFetchedResultsController {
    NSFetchedResultsController *fetchedResultsController = [self.localDeckService createFetchedResultsController];
    fetchedResultsController.delegate = self;
    [self.localDeckService.contextQueue addOperationWithBlock:^{
        NSError * _Nullable error = nil;
        [fetchedResultsController performFetch:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    self.fetchedResultsController = fetchedResultsController;
}

- (void)configureBackgroundQueue {
    NSOperationQueue *backgroundQueue = [NSOperationQueue new];
    backgroundQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    self.backgroundQueue = backgroundQueue;
}

- (void)configureCancellableBag {
    CancellableBag *cancellableBag = [CancellableBag new];
    self.cancellableBag = cancellableBag;
}

- (void)bind {
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [self.dataSourceQueue addOperationWithBlock:^{
        [self.dataSource applySnapshotAndWait:snapshot animatingDifferences:YES completion:^{
            
        }];
    }];
}

@end
