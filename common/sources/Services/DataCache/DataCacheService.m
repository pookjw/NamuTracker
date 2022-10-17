//
//  DataCacheService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import "DataCacheService.h"
#import <CoreData/CoreData.h>
#import "identifiers.h"

#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
#import "isMockMode.h"
#endif
#endif

@interface DataCacheService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *contextQueue;
@end

@implementation DataCacheService

+ (DataCacheService *)sharedInstance {
    static DataCacheService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [DataCacheService new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configureContainer];
        [self configureContext];
        [self configureContextQueue];
    }
    
    return self;
}

- (void)dealloc {
    [self.contextQueue cancelAllOperations];
}

- (void)fetchDataCachesWithIdentity:(NSString *)identity completion:(DataCacheServiceFetchDataCachesWithIdentityCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataCache"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"identity", identity]];
        fetchRequest.predicate = predicate;
        
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<DataCache *> *results = [self.context executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"%@", error);
                completion(nil, error);
                return;
            }
            completion(results, nil);
        }];
    }];
}

- (void)createDataCacheWithCompletion:(DataCacheServiceCreateDataCacheCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        DataCache *dataCache = [[DataCache alloc] initWithContext:self.context];
        NSError * _Nullable error = nil;
        if (error) {
            NSLog(@"%@", error);
            completion(nil, error);
            return;
        }
        completion(dataCache, nil);
    }];
}

- (void)deleteAllDataCachesWithCompletion:(DataCacheServiceDeleteAllDataCachesCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DataCache"];
        NSBatchDeleteRequest *batchDelete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        batchDelete.affectedStores = self.container.persistentStoreCoordinator.persistentStores;
        
        NSError * _Nullable error = nil;
        [self.container.persistentStoreCoordinator executeRequest:batchDelete withContext:self.context error:&error];
        if (error) {
            NSLog(@"%@", error);
            completion(error);
            return;
        }
        completion(nil);
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

- (void)configureContainer {
    NSString *entityName = @"DataCache";
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
    self.contextQueue = contextQueue;
}

@end
