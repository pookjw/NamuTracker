#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "AlternativeHSCard.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CardServiceHSCardCompletion)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^CardServiceHSCardsCompletion)(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error);

@interface CardService : NSObject
- (AlternativeHSCard *)alternativeHSCardWithCardId:(NSString *)cardId;
- (CancellableObject *)hsCardWithCardId:(NSString *)cardId completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardWithDbfId:(NSUInteger)dbfId completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardsFromSelectedDeckWithCompletion:(CardServiceHSCardsCompletion)completio;
@end

NS_ASSUME_NONNULL_END
