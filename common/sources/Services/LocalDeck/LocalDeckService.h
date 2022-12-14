//
//  LocalDeckService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import <CoreData/CoreData.h>
#import "LocalDeck.h"

NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const NSNotificationNameLocalDeckServiceDidSave = @"NSNotificationNameLocalDeckServiceDidSave";

typedef void (^LocalDeckServiceFetchLocalDecksCompletion)(NSArray<LocalDeck *> * _Nullable localDecks, NSError * _Nullable error);
typedef void (^LocalDeckServiceFetchObjectIDsCompletion)(NSArray<NSManagedObjectID *> * _Nullable objectIDs, NSError * _Nullable error);
typedef void (^LocalDeckServiceFetchSelectedLocalDeckCompletion)(LocalDeck * _Nullable localDeck, NSError * _Nullable error);
typedef void (^LocalDeckServiceFetchLocalDecksCountCompletion)(NSUInteger count, NSError * _Nullable error);
typedef void (^LocalDeckServiceCreateLocalDeckCompletion)(LocalDeck * _Nullable localDeck, NSError * _Nullable error);
typedef void (^LocalDeckServiceRefreshLocalDeckCompletion)(void);

@interface LocalDeckService : NSObject
@property (class, readonly, strong, nonatomic) LocalDeckService *sharedInstance;
@property (readonly, strong) NSOperationQueue *contextQueue;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)refreshLocalDeck:(LocalDeck *)localDeck completion:(LocalDeckServiceRefreshLocalDeckCompletion)completion;
- (void)fetchLocalDecksWithCompletion:(LocalDeckServiceFetchLocalDecksCompletion)completion;
- (void)fetchObjectIdsWithCompletion:(LocalDeckServiceFetchObjectIDsCompletion)completion;
- (void)fetchSelectedLocalDeckWithCompletion:(LocalDeckServiceFetchSelectedLocalDeckCompletion)completion;
- (void)fetchLocalDecksCountWithCompletion:(LocalDeckServiceFetchLocalDecksCountCompletion)completion;
- (void)createLocalDeckWithCompletion:(LocalDeckServiceCreateLocalDeckCompletion)completion;
- (void)deleteLocalDecks:(NSSet<LocalDeck *> *)localDecks;
- (void)deleteLocalDecksWithObjectIds:(NSSet<NSManagedObjectID *> *)objectIds;
- (void)saveChanges;
- (NSFetchedResultsController *)createFetchedResultsController;
@end

NS_ASSUME_NONNULL_END
