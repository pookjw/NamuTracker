#import <Foundation/Foundation.h>

typedef NSNotificationName HSLogServiceNotificationName NS_TYPED_EXTENSIBLE_ENUM;
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidStartTheGame = @"HSLogServiceNotificationNameDidStartTheGame";
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidEndTheGame = @"HSLogServiceNotificationNameDidEndTheGame";
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidRemoveCardFromDeck = @"HSLogServiceNotificationNameDidRemoveCardFromDeck";
static HSLogServiceNotificationName const HSLogServiceNotificationNameDidAddCardToDeck = @"HSLogServiceNotificationNameDidAddCardToDeck";

static NSString * const HSLogServiceHSCardUserInfoKey = @"HSLogServiceHSCardUserInfoKey";

@interface HSLogService : NSObject
@property (class, readonly, strong) HSLogService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)installCustomLogConfiguration;
- (void)startObserving;
- (void)stopObserving;
@end
