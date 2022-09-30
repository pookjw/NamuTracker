#import <Foundation/Foundation.h>

typedef NSNotificationName HSLogServiceNotificationName NS_TYPED_EXTENSIBLE_ENUM;
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidStartTheGame = @"HSLogServiceNotificationNameDidStartTheGame";
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidEndTheGame = @"HSLogServiceNotificationNameDidEndTheGame";
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidChangeCards = @"HSLogServiceNotificationNameDidChangeCards";

static NSString * const HSLogServiceAddedAlternativeHSCardsUserInfoKey = @"HSLogServiceAddedAlternativeHSCardsUserInfoKey";
static NSString * const HSLogServiceRemovedAlternativeHSCardsUserInfoKey = @"HSLogServiceRemovedAlternativeHSCardsUserInfoKey";

@interface HSLogService : NSObject
@property (class, readonly, strong, nonatomic) HSLogService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)installCustomLogConfiguration;
- (void)startObserving;
- (void)stopObserving;
@end
