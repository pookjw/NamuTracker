#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "AlternativeHSCard.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CardServiceAlternativeHSCardCompletion)(AlternativeHSCard * _Nullable alternativeHSCard, NSError * _Nullable error);
typedef void (^CardServiceHSCardCompletion)(HSCard * _Nullable hsCard, NSError * _Nullable error);
typedef void (^CardServiceHSCardsCompletion)(NSArray<HSCard *> * _Nullable hsCards, NSError * _Nullable error);

@interface CardService : NSObject
- (void)alternativeHSCardWithCardId:(NSString *)cardId completion:(CardServiceAlternativeHSCardCompletion)completion;
- (CancellableObject *)hsCardWithCardId:(NSString *)cardId completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardWithDbfId:(NSNumber *)dbfId completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completion:(CardServiceHSCardCompletion)completion;
- (CancellableObject *)hsCardsFromSelectedDeckWithCompletion:(CardServiceHSCardsCompletion)completio;
@end

NS_ASSUME_NONNULL_END
