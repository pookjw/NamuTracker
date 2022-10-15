//
//  LocalDeckService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import "LocalDeckService.h"
#import "isMockMode.h"
#import "identifiers.h"

@interface LocalDeckService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *backgroundQueue;
@property (readonly, nonatomic) NSFetchRequest *fetchRequest;
@end

@implementation LocalDeckService

+ (LocalDeckService *)sharedInstance {
    static LocalDeckService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [LocalDeckService new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configureContainer];
        [self configureContext];
        [self configureContextQueue];
        [self configureBackgroundQueue];
        [self bind];
    }
    
    return self;
}

- (void)dealloc {
    [self.contextQueue cancelAllOperations];
    [self.backgroundQueue cancelAllOperations];
}

- (void)refreshLocalDeck:(LocalDeck *)localDeck completion:(LocalDeckServiceRefreshLocalDeckCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            [self.context refreshObject:localDeck mergeChanges:YES];
            completion();
        }];
    }];
}

- (void)fetchLocalDecksWithCompletion:(LocalDeckServiceFetchLocalDecksCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<LocalDeck *> *results = [self.context executeFetchRequest:self.fetchRequest error:&error];
            
            if (error) {
                completion(nil, error);
                return;
            }
            
            completion(results, nil);
        }];
    }];
}

- (void)fetchObjectIdsWithCompletion:(LocalDeckServiceFetchObjectIDsCompletion)completion {
    [self fetchLocalDecksWithCompletion:^(NSArray<LocalDeck *> * _Nullable localDecks, NSError * _Nullable error) {
        [self.backgroundQueue addOperationWithBlock:^{
            if (error) {
                completion(nil, error);
                return;
            }
            
            NSMutableArray<NSManagedObjectID *> *objectIds = [NSMutableArray<NSManagedObjectID *> new];
            
            [localDecks enumerateObjectsUsingBlock:^(LocalDeck * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [objectIds addObject:obj.objectID];
            }];
            
            completion([objectIds copy], nil);
        }];
    }];
}

- (void)createLocalDeckWithCompletion:(LocalDeckServiceNewLocalDeckCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        LocalDeck *localDeck = [[LocalDeck alloc] initWithContext:self.context];
        NSError * _Nullable error = nil;
        [self.context obtainPermanentIDsForObjects:@[localDeck] error:&error];
        if (error) {
            NSLog(@"%@", error);
            completion(nil, error);
            return;
        }
        completion(localDeck, nil);
    }];
}

- (void)deleteLocalDecks:(NSSet<LocalDeck *> *)localDecks {
    [self.contextQueue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            [localDecks enumerateObjectsUsingBlock:^(LocalDeck * _Nonnull obj, BOOL * _Nonnull stop) {
                [self.context deleteObject:obj];
            }];
            
            NSError * _Nullable error = nil;
            [self.context save:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    }];
}

- (void)deleteLocalDecksWithObjectIds:(NSSet<NSManagedObjectID *> *)objectIds {
    [self.contextQueue addOperationWithBlock:^{
        NSMutableSet<LocalDeck *> *localDecks = [NSMutableSet<LocalDeck *> new];
        
        [objectIds enumerateObjectsUsingBlock:^(NSManagedObjectID * _Nonnull obj, BOOL * _Nonnull stop) {
            NSError * _Nullable error = nil;
            LocalDeck * _Nullable localDeck = [self.context existingObjectWithID:obj error:&error];
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            [localDecks addObject:localDeck];
        }];
        
        [self deleteLocalDecks:localDecks];
    }];
}

- (void)saveChanges {
    [self.contextQueue addOperationWithBlock:^{
        if (!self.context.hasChanges) return;
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            [self.context save:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    }];
}

- (NSFetchedResultsController *)createFetchedResultsController {
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                                               managedObjectContext:self.context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    return fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocalDeck"];
    NSSortDescriptor *timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    fetchRequest.sortDescriptors = @[timestampSortDescriptor, indexSortDescriptor];
    
    return fetchRequest;
}

- (void)configureContainer {
    NSURL *momURL;
    
    if (isMockMode()) {
        momURL = [NSBundle.mainBundle URLForResource:@"LocalDeck" withExtension:@"mom" subdirectory:@"LocalDeck.momd"];
    } else {
        momURL = [[[[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"momd"] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"mom"];
    }
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"LocalDeck" managedObjectModel:managedObjectModel];
    
    if (!isMockMode()) {
        if (![NSFileManager.defaultManager fileExistsAtPath:NamuTrackerSharedDataLibraryURLString]) {
            NSError * _Nullable error = nil;
            [NSFileManager.defaultManager createDirectoryAtURL:[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSURL *dbURL = [[[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"sqlite"];
        NSPersistentStoreDescription *description = [[NSPersistentStoreDescription alloc] initWithURL:dbURL];
        description.readOnly = NO;
        container.persistentStoreDescriptions = @[description];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
        
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    self.container = container;
}

- (void)configureContext {
    NSManagedObjectContext *context = self.container.newBackgroundContext;
    context.automaticallyMergesChangesFromParent = YES;
    self.context = context;
}

- (void)configureContextQueue {
    NSOperationQueue *contextQueue = [NSOperationQueue new];
    contextQueue.qualityOfService = NSQualityOfServiceUtility;
    contextQueue.maxConcurrentOperationCount = 1;
    self->_contextQueue = contextQueue;
}

- (void)configureBackgroundQueue {
    NSOperationQueue *backgroundQueue = [NSOperationQueue new];
    backgroundQueue.qualityOfService = NSQualityOfServiceUtility;
    self.backgroundQueue = backgroundQueue;
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedDidSaveNotification:)
                                               name:NSManagedObjectContextDidSaveNotification
                                             object:self.context];
}

- (void)receivedDidSaveNotification:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameLocalDeckServiceDidSave
                                                      object:self
                                                    userInfo:nil];
}

@end
