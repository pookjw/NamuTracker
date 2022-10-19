//
//  AlternativeHSCardService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import "AlternativeHSCardService.h"
#import "identifiers.h"
#import "keys.h"
#import <CoreData/CoreData.h>

#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
#import "isMockMode.h"
#endif
#endif

typedef NSString * RapidAPIHearthstoneAPI NS_STRING_ENUM;

@interface AlternativeHSCardService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *contextQueue;
@property (strong) NSOperationQueue *backgroundQueue;
@end

@implementation AlternativeHSCardService

+ (AlternativeHSCardService *)sharedInstance {
    static AlternativeHSCardService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [AlternativeHSCardService new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configureContainer];
        [self configureContext];
        [self configureContextQueue];
        [self configureBackgroundQueue];
    }
    
    return self;
}

- (void)dealloc {
    [self.contextQueue cancelAllOperations];
    [self.backgroundQueue cancelAllOperations];
}

- (CancellableObject *)reloadAlternativeHSCardsWithCompletion:(AlternativeHSCardServiceReloadAlternativeHSCardsCompletion)completion {
    __block CancellableObject * _Nullable rapidAPICardsCancellable = nil;
    
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [rapidAPICardsCancellable cancel];
    }];
    
    [self deleteAllDataCachesWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        
        rapidAPICardsCancellable = [self rapidAPICardsDataWithCompletion:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@", error);
                completion(error);
                return;
            }
            
            [self.backgroundQueue addOperationWithBlock:^{
                NSError * _Nullable serializationError = nil;
                NSDictionary<NSString *, NSArray<NSDictionary<NSString *, id> *> *> *cardsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
                if (serializationError) {
                    NSLog(@"%@", serializationError);
                    completion(serializationError);
                    return;
                }
                
                [self.contextQueue addOperationWithBlock:^{
                    [cardsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSDictionary<NSString *,id> *> * _Nonnull obj1, BOOL * _Nonnull stop) {
                        [obj1 enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                            AlternativeHSCard *alternativeHSCard = [[AlternativeHSCard alloc] initWithContext:self.context];
                            [alternativeHSCard synchronizeWithDictionary:obj2];
                        }];
                    }];
                    
                    [self.context performBlockAndWait:^{
                        NSError * _Nullable error = nil;
                        [self.context save:&error];
                        if (error) {
                            NSLog(@"%@", error);
                            completion(error);
                            return;
                        }
                        completion(nil);
                    }];
                }];
            }];
        }];
    }];
    
    return cancellable;
}

- (void)fetchAlternativeHSCardFromCardId:(NSString *)cardId completion:(AlternativeHSCardServiceFetchAlternativeHSCardFromCardIdCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AlternativeHSCard"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"cardId", cardId]];
        fetchRequest.predicate = predicate;
        
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<AlternativeHSCard *> *results = [self.context executeFetchRequest:fetchRequest error:&error];
            
            if (error) {
                NSLog(@"%@", error);
                completion(nil, error);
                return;
            }
            
            completion(results.lastObject, nil);
        }];
    }];
}

- (void)deleteAllDataCachesWithCompletion:(AlternativeHSCardServiceDeleteAllDataCachesCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"AlternativeHSCard"];
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

- (void)configureContainer {
    NSString *entityName = @"AlternativeHSCard";
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

- (void)configureBackgroundQueue {
    NSOperationQueue *backgroundQueue = [NSOperationQueue new];
    backgroundQueue.qualityOfService = NSQualityOfServiceUtility;
    self.backgroundQueue = backgroundQueue;
}

- (CancellableObject *)rapidAPICardsDataWithCompletion:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completion {
    NSURLComponents *components = [NSURLComponents new];
    
    components.scheme = @"https";
    components.host = @"omgvamp-hearthstone-v1.p.rapidapi.com";
    components.path = @"/cards";
    
    NSURL *url = components.URL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = @{
        @"X-RapidAPI-Key": NamuTrackerKeyRapidAPIKey,
        @"X-RapidAPI-Host": @"omgvamp-hearthstone-v1.p.rapidapi.com"
    };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        completion(data, nil);
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
    
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [task cancel];
    }];
    
    return cancellable;
}

@end
