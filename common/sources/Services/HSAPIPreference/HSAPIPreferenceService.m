//
//  HSAPIPreferenceService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import "HSAPIPreferenceService.h"
#import "HSAPIPreference.h"
#import "identifiers.h"

#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
#import "isMockMode.h"
#endif
#endif

@interface HSAPIPreferenceService ()
@property (strong) NSPersistentContainer *container;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSOperationQueue *contextQueue;
@property (strong) NSOperationQueue *backgroundQueue;
@property (readonly, nonatomic) NSFetchRequest *fetchRequest;
@property (readonly, nonatomic) HSAPIRegionHost defaultRegionHost;
@property (readonly, nonatomic) HSAPILocale defaultLocale;
@end

@implementation HSAPIPreferenceService

+ (HSAPIPreferenceService *)sharedInstance {
    static HSAPIPreferenceService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [HSAPIPreferenceService new];
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
}

- (void)fetchRegionHostAndLocaleWithCompletion:(HSAPIPreferenceServiceFetchRegionHostAndLocaleCompletion)completion {
    [self fetchHSAPIPreferenceServiceWithCompletion:^(HSAPIPreference * _Nullable hsAPIPreference, NSError * _Nullable error) {
        [self.backgroundQueue addOperationWithBlock:^{
            NSNumber * _Nullable regionHostNumber = hsAPIPreference.regionHost;
            HSAPILocale _Nullable locale = hsAPIPreference.locale;
            
            HSAPIRegionHost regionHost;
            if (regionHostNumber) {
                regionHost = regionHostNumber.unsignedIntegerValue;
            } else {
                regionHost = self.defaultRegionHost;
            }
            
            if (locale == nil) {
                locale = self.defaultLocale;
            }
            
            completion(regionHost, locale);
        }];
    }
                                      createIfEmpty:NO];
}

- (void)updateRegionHost:(HSAPIRegionHost)regionHost {
    [self fetchHSAPIPreferenceServiceWithCompletion:^(HSAPIPreference * _Nullable hsAPIPreference, NSError * _Nullable error) {
        hsAPIPreference.regionHost = @(regionHost);
        [self saveChanges];
    }
                                      createIfEmpty:YES];
}

- (void)updateLocale:(HSAPILocale)locale {
    [self fetchHSAPIPreferenceServiceWithCompletion:^(HSAPIPreference * _Nullable hsAPIPreference, NSError * _Nullable error) {
        hsAPIPreference.locale = locale;
        [self saveChanges];
    }
                                      createIfEmpty:YES];
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HSAPIPreference"];
    return fetchRequest;
}

- (HSAPIRegionHost)defaultRegionHost {
    NSLocale *locale = NSLocale.currentLocale;
    NSString * _Nullable countryCode = locale.countryCode;
    
    if ([countryCode isEqualToString:@"US"]) {
        return HSAPIRegionHostUS;
    } else if ([countryCode isEqualToString:@"EU"]) {
        return HSAPIRegionHostEU;
    } else if ([countryCode isEqualToString:@"KR"]) {
        return HSAPIRegionHostKR;
    } else if ([countryCode isEqualToString:@"TW"]) {
        return HSAPIRegionHostTW;
    } else if ([countryCode isEqualToString:@"CN"]) {
        return HSAPIRegionHostCN;
    } else {
        return HSAPIRegionHostUS;
    }
}

- (HSAPILocale)defaultLocale {
    NSString *language = NSLocale.preferredLanguages.firstObject;
    NSString *localeIdentifier = NSLocale.currentLocale.localeIdentifier;

    if ([language containsString:@"en"]) {
        return HSAPILocaleEnUS;
    } else if ([language containsString:@"fr"]) {
        return HSAPILocaleFrFR;
    } else if ([language containsString:@"de"]) {
        return HSAPILocaleDeDE;
    } else if ([language containsString:@"it"]) {
        return HSAPILocaleItIT;
    } else if ([language containsString:@"ja"]) {
        return HSAPILocaleJaJP;
    } else if ([language containsString:@"ko"]) {
        return HSAPILocaleKoKR;
    } else if ([language containsString:@"pl"]) {
        return HSAPILocalePlPL;
    } else if ([language containsString:@"ru"]) {
        return HSAPILocaleRuRU;
    } else if ([localeIdentifier containsString:@"zh_CN"]) {
        return HSAPILocaleZhCN;
    } else if ([language containsString:@"es"]) {
        return HSAPILocaleKoKR;
    } else if ([localeIdentifier containsString:@"zh_TW"]) {
        return HSAPILocaleZhTW;
    } else {
        return HSAPILocaleEnUS;
    }
}

- (void)configureContainer {
    BOOL _isMockMode = NO;
#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
    _isMockMode = isMockMode();
#endif
#endif
    
    NSURL *momURL;
    
    if (_isMockMode) {
        momURL = [NSBundle.mainBundle URLForResource:@"HSAPIPreference" withExtension:@"mom" subdirectory:@"HSAPIPreference.momd"];
    } else {
        momURL = [[[[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:@"HSAPIPreference"] URLByAppendingPathExtension:@"momd"] URLByAppendingPathComponent:@"HSAPIPreference"] URLByAppendingPathExtension:@"mom"];
    }
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"HSAPIPreference" managedObjectModel:managedObjectModel];
    
    if (!_isMockMode) {
        if (![NSFileManager.defaultManager fileExistsAtPath:NamuTrackerSharedDataLibraryURLString]) {
            NSError * _Nullable error = nil;
            [NSFileManager.defaultManager createDirectoryAtURL:[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSURL *dbURL = [[[NSURL fileURLWithPath:NamuTrackerSharedDataLibraryURLString] URLByAppendingPathComponent:@"HSAPIPreference"] URLByAppendingPathExtension:@"sqlite"];
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

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedDidSaveNotification:)
                                               name:NSManagedObjectContextDidSaveNotification
                                             object:self.context];
}

- (void)receivedDidSaveNotification:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameHSAPIPreferenceServiceDidSave
                                                      object:self
                                                    userInfo:nil];
}

- (void)fetchHSAPIPreferenceServiceWithCompletion:(void (^)(HSAPIPreference * _Nullable hsAPIPreference, NSError * _Nullable error))completion createIfEmpty:(BOOL)createIfEmpty {
    [self.contextQueue addOperationWithBlock:^{
        [self.context performBlockAndWait:^{
            NSError * _Nullable error = nil;
            NSArray<HSAPIPreference *> *hsAPIPreferences = [self.context executeFetchRequest:self.fetchRequest error:&error];
            
            if (error) {
                completion(nil, error);
                return;
            }
            
            HSAPIPreference * _Nullable hsAPIPreference = hsAPIPreferences.firstObject;
            
            if ((createIfEmpty) && (hsAPIPreference == nil)) {
                [self.contextQueue addOperationWithBlock:^{
                    HSAPIPreference *hsAPIPreference = [[HSAPIPreference alloc] initWithContext:self.context];
                    NSError * _Nullable error = nil;
                    [self.context obtainPermanentIDsForObjects:@[hsAPIPreference] error:&error];
                    if (error) {
                        completion(nil, error);
                        return;
                    }
                    completion(hsAPIPreference, nil);
                }];
            } else {
                completion(hsAPIPreference, nil);
            }
        }];
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

@end
