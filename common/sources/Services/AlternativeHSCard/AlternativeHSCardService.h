//
//  AlternativeHSCardService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <Foundation/Foundation.h>
#import "AlternativeHSCard.h"
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^AlternativeHSCardServiceReloadAlternativeHSCardsCompletion)(NSError * _Nullable error);
typedef void (^AlternativeHSCardServiceFetchAlternativeHSCardFromCardIdCompletion)(AlternativeHSCard * _Nullable alternativeHSCard, NSError * _Nullable error);
typedef void (^AlternativeHSCardServiceDeleteAllDataCachesCompletion)(NSError * _Nullable error);

@interface AlternativeHSCardService : NSObject
@property (class, readonly, strong, nonatomic) AlternativeHSCardService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (CancellableObject *)reloadAlternativeHSCardsWithCompletion:(AlternativeHSCardServiceReloadAlternativeHSCardsCompletion)completion;
- (void)fetchAlternativeHSCardFromCardId:(NSString *)cardId completion:(AlternativeHSCardServiceFetchAlternativeHSCardFromCardIdCompletion)completion;
- (void)deleteAllDataCachesWithCompletion:(AlternativeHSCardServiceDeleteAllDataCachesCompletion)completion;
@end

NS_ASSUME_NONNULL_END
