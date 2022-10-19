//
//  LocalDeckService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import "LocalDeckService.h"
#import "identifiers.h"
#import "MessagingService.h"
#import <UIKit/UIKit.h>

#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
#import "isMockMode.h"
#endif
#endif

static NSString *LocalDeckServiceMessagingServiceDidSaveName = @"LocalDeckServiceMessagingServiceDidSaveName";

@interface LocalDeckService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *backgroundQueue;
@property (readonly, nonatomic) NSFetchRequest *fetchRequest;
@property (strong) MessagingService *messagingService;
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
        [self configureMessagingService];
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

- (void)fetchSelectedLocalDeckWithCompletion:(LocalDeckServiceFetchSelectedLocalDeckCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocalDeck"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"selected", @(YES)]];
        fetchRequest.predicate = predicate;
        
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<LocalDeck *> *results = [self.context executeFetchRequest:fetchRequest error:&error];
            
            if (error) {
                NSLog(@"%@", error);
                completion(nil, error);
                return;
            }
            
            completion(results.lastObject, nil);
        }];
    }];
}

- (void)fetchLocalDecksCountWithCompletion:(LocalDeckServiceFetchLocalDecksCountCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = self.fetchRequest;
        fetchRequest.includesSubentities = NO;
        
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSUInteger count = [self.context countForFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"%@", error);
                completion(NSNotFound, error);
                return;
            }
            
            completion(count, nil);
        }];
    }];
}

- (void)createLocalDeckWithCompletion:(LocalDeckServiceCreateLocalDeckCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        LocalDeck *localDeck = [[LocalDeck alloc] initWithContext:self.context];
        NSError * _Nullable error = nil;
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
    NSString *entityName = @"LocalDeck";
    BOOL _isMockMode = NO;
#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
    _isMockMode = isMockMode();
#endif
#endif
    
    NSURL *momURL;
    
    if (_isMockMode) {
        momURL = [NSBundle.mainBundle URLForResource:entityName withExtension:@"mom" subdirectory:[NSString stringWithFormat:@"%@.momd", entityName]];
    } else {
        momURL = [[[[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:entityName] URLByAppendingPathExtension:@"momd"] URLByAppendingPathComponent:entityName] URLByAppendingPathExtension:@"mom"];
    }
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:entityName managedObjectModel:managedObjectModel];
    
    if (!_isMockMode) {
        if (![NSFileManager.defaultManager fileExistsAtPath:NamuTrackerSharedDataLibraryURLString]) {
            NSError * _Nullable error = nil;
            [NSFileManager.defaultManager createDirectoryAtURL:[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSURL *dbURL = [[[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] URLByAppendingPathComponent:entityName] URLByAppendingPathExtension:@"sqlite"];
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

- (void)configureMessagingService {
    MessagingService *messagingService = MessagingService.sharedInstance;
    self.messagingService = messagingService;
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedDidSaveNotification:)
                                               name:NSManagedObjectContextDidSaveNotification
                                             object:self.context];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedWillEnterForegroundNotification:)
                                               name:UISceneWillEnterForegroundNotification
                                             object:nil];
    
    [self.messagingService registerForMessageName:LocalDeckServiceMessagingServiceDidSaveName
                                           target:self
                                         selector:@selector(receivedMessageName:userInfo:)
                                       completion:^{
        
    }];
}

- (void)receivedDidSaveNotification:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameLocalDeckServiceDidSave
                                                      object:self
                                                    userInfo:nil];
}

- (void)receivedWillEnterForegroundNotification:(NSNotification *)notification {
    [self.contextQueue addOperationWithBlock:^{
        [self.context refreshAllObjects];
        [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameLocalDeckServiceDidSave
                                                          object:self
                                                        userInfo:nil];
    }];
}

- (void)receivedMessageName:(NSString *)messageName userInfo:(NSDictionary *)userInfo {
    [self.contextQueue addOperationWithBlock:^{
        [self.context refreshAllObjects];
        [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameLocalDeckServiceDidSave
                                                          object:self
                                                        userInfo:nil];
    }];
}

@end
