#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "HSDeck.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HSAPIServiceHSCardCompletionHandler)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^HSAPIServiceHSDeckCompletionHandler)(HSDeck * _Nullable hsDeck, NSError * _Nullable error);

@interface HSAPIService : NSObject
- (CancellableObject *)hsCardWithIdOrSlug:(NSString *)idOrSlug
              completionHandler:(HSAPIServiceHSCardCompletionHandler)completionHandler;
- (CancellableObject *)hsDeckFromDeckCode:(NSString *)deckCode
         completionHandler:(HSAPIServiceHSDeckCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
