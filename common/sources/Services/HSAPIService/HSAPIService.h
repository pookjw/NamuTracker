#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "HSDeck.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HSAPIServiceHSCardCompletion)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^HSAPIServiceHSDeckCompletion)(HSDeck * _Nullable hsDeck, NSError * _Nullable error);

@interface HSAPIService : NSObject
- (CancellableObject *)hsCardWithIdOrSlug:(NSString *)idOrSlug
                               completion:(HSAPIServiceHSCardCompletion)completion;
- (CancellableObject *)hsDeckFromDeckCode:(NSString *)deckCode
                               completion:(HSAPIServiceHSDeckCompletion)completion;
@end

NS_ASSUME_NONNULL_END
