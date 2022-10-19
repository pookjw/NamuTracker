//
//  MessagingService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MessagingServiceRegisterCompletion)(void);
typedef void (^MessagingServiceUnregisterCompletion)(void);
typedef void (^MessagingServiceSendMessageCompletion)(id _Nullable reply, NSError * _Nullable error);

@interface MessagingService : NSObject
@property (class, readonly, strong, nonatomic) MessagingService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)registerForMessageName:(NSString *)name target:(id)target selector:(SEL)selector completion:(MessagingServiceRegisterCompletion)completion;
- (void)unregisterForMessageName:(NSString *)name completion:(MessagingServiceUnregisterCompletion)completion;
- (void)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary * _Nullable)userInfo completion:(MessagingServiceSendMessageCompletion)completion;
@end

NS_ASSUME_NONNULL_END
