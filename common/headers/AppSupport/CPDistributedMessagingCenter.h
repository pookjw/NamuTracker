//
//  CPDistributedMessagingCenter.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

#import <Foundation/Foundation.h>

@interface CPDistributedMessagingCenter : NSObject
+ (instancetype)centerNamed:(NSString *)arg1;
+ (instancetype)pidRestrictedCenterNamed:(id)arg1;
+ (instancetype)_centerNamed:(id)arg1 requireLookupByPID:(BOOL)arg2;
- (unsigned int) _sendPort;
- (void)stopServer;
- (instancetype)_initWithServerName:(id)arg1 requireLookupByPID:(BOOL)arg2;
- (NSString *)name;
- (void)_setupInvalidationSource;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
- (instancetype)_initClientWithPort:(unsigned int)arg1;
- (instancetype)_initAnonymousServer;
- (void)unregisterForMessageName:(NSString *)name;
- (BOOL)_isTaskEntitled:(void *)arg1;
- (void)_setSendPort:(unsigned int)arg1;
- (void)setTargetPID:(int)arg1;
- (void)_dispatchMessageNamed:(id)arg1 userInfo:(id)arg2 reply:(id*)arg3 auditToken:(void *)arg4;
- (id)delayReply;
- (void)registerForMessageName:(NSString *)arg1 target:(id)arg2 selector:(SEL)arg3;
- (BOOL)doesServerExist;
- (void)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2 toTarget:(id)arg3 selector:(SEL)arg4 context:(void*)arg5;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (id)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary *)userInfo error:(NSError **)error;
- (unsigned int)_serverPort;
- (BOOL)_sendMessage:(id)arg1 userInfo:(id)arg2 receiveReply:(id*)arg3 error:(id*)arg4 toTarget:(id)arg5 selector:(SEL)arg6 context:(void*)arg7 nonBlocking:(BOOL)arg8;
- (id)_requiredEntitlement;
- (void)runServerOnCurrentThreadProtectedByEntitlement:(id)arg1;
- (void)_sendReplyMessage:(id)arg1 portPassing:(BOOL)arg2 onMachPort:(unsigned int)arg3;
- (instancetype)_initWithServerName:(id)arg1;
- (BOOL)sendNonBlockingMessageName:(id)arg1 userInfo:(id)arg2;
- (void)runServerOnCurrentThread;
- (BOOL)_sendMessage:(id)arg1 userInfo:(id)arg2 receiveReply:(id*)arg3 error:(id*)arg4 toTarget:(id)arg5 selector:(SEL)arg6 context:(void*)arg7;
- (void)sendDelayedReply:(id)arg1 dictionary:(id)arg2;
- (BOOL)_sendMessage:(id)arg1 userInfoData:(id)arg2 oolKey:(id)arg3 oolData:(id)arg4 makeServer:(BOOL)arg5 receiveReply:(id*)arg6 nonBlocking:(BOOL)arg7 error:(id*)arg8;
@end
