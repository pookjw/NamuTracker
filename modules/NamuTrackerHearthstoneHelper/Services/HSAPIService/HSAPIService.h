#import <Foundation/Foundation.h>
#import "HSCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HSAPIServiceHSCardCompletionHandler)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^HSAPIServiceHSCardsCompletionHandler)(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error);

@interface HSAPIService : NSObject
- (void)hsCardWithIdOrSlug:(NSString *)idOrSlug
              completionHandler:(HSAPIServiceHSCardCompletionHandler)completionHandler;
- (void)hsCardsFromDeckCode:(NSString *)deckCode
               completionHandler:(HSAPIServiceHSCardsCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
