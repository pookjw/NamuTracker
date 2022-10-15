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

@interface DecksViewModel () <NSFetchedResultsControllerDelegate>
@property (strong) DecksViewModelDataSource *dataSource;
@property (strong) NSOperationQueue *dataSourceQueue;
@property (strong) LocalDeckService *localDeckService;
@property (strong) HSAPIService *hsAPIService;
@property (strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation DecksViewModel

- (instancetype)initWithDataSource:(DecksViewModelDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        [self configureDataSourceQueue];
        [self configureLocalDeckService];
        [self configureHSAPIService];
        [self configureFetchedResultsController];
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

- (void)bind {
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [self.dataSourceQueue addOperationWithBlock:^{
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES completion:^{
            
        }];
    }];
}

@end
