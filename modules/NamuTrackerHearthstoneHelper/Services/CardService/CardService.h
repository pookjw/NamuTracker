#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "AlternativeHSCard.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CardServiceHSCardCompletionHandler)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^CardServiceHSCardsCompletionHandler)(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error);

@interface CardService : NSObject
- (AlternativeHSCard *)alternativeHSCardWithCardId:(NSString *)cardId;
- (CancellableObject *)hsCardWithCardId:(NSString *)cardId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (CancellableObject *)hsCardWithDbfId:(NSUInteger)dbfId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (CancellableObject *)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (CancellableObject *)hsCardsFromSelectedDeckWithCompletionHandler:(CardServiceHSCardsCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
