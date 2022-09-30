#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "AlternativeHSCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CardServiceHSCardCompletionHandler)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^CardServiceHSCardsCompletionHandler)(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error);

@interface CardService : NSObject
- (AlternativeHSCard *)alternativeHSCardWithCardId:(NSString *)cardId;
- (void)hsCardWithCardId:(NSString *)cardId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (void)hsCardWithDbfId:(NSUInteger)dbfId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (void)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completionHandler:(CardServiceHSCardCompletionHandler)completionHandler;
- (void)hsCardsFromSelectedDeckWithCompletionHandler:(CardServiceHSCardsCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
