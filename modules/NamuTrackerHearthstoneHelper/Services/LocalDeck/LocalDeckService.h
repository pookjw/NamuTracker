#import <CoreData/CoreData.h>
#import "LocalDeck.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LocalDeckServiceFetchSelectedLocalDeckCompletion)(LocalDeck * _Nullable localDeck, NSError * _Nullable error);

@interface LocalDeckService : NSObject
@property (class, readonly, strong, nonatomic) LocalDeckService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)fetchSelectedLocalDeckWithCompletion:(LocalDeckServiceFetchSelectedLocalDeckCompletion)completion;
@end

NS_ASSUME_NONNULL_END
