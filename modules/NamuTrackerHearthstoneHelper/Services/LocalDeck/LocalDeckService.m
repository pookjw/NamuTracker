#import "LocalDeckService.h"
#import "identifiers.h"

@interface LocalDeckService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *contextQueue;
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
    }

    return self;
}

- (void)dealloc {
    [self.contextQueue cancelAllOperations];
}

- (void)fetchSelectedLocalDeckWithCompletion:(LocalDeckServiceFetchSelectedLocalDeckCompletion)completion {
    [self.contextQueue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<LocalDeck *> *results = [self.context executeFetchRequest:self.fetchRequest error:&error];

            if (error) {
                completion(nil, error);
                return;
            }

            completion(results.lastObject, nil);
        }];
    }];
}

- (void)configureContainer {
    NSURL *momURL = [[[[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"momd"] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"mom"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"LocalDeck" managedObjectModel:managedObjectModel];

    NSURL *dbURL = [[[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] URLByAppendingPathComponent:@"LocalDeck"] URLByAppendingPathExtension:@"sqlite"];
    NSPersistentStoreDescription *description = [[NSPersistentStoreDescription alloc] initWithURL:dbURL];
    description.readOnly = YES;
    container.persistentStoreDescriptions = @[description];

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

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocalDeck"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"selected", @(YES)]];
    fetchRequest.predicate = predicate;
    
    return fetchRequest;
}

@end
