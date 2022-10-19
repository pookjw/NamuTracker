//
//  MessagingService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

/* https://iphonedev.wiki/index.php/RocketBootstrap */

#import "MessagingService.h"
#import "CPDistributedMessagingCenter.h"
#import "identifiers.h"
#import "rocketbootstrap.h"
#import <objc/message.h>
#import <dlfcn.h>

#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
#import "isMockMode.h"
#endif
#endif

@interface MessagingService ()
@property (strong) NSOperationQueue *messagingQueue;
@property (strong) CPDistributedMessagingCenter *distributedMessagingCenter;
@end

@implementation MessagingService

+ (MessagingService *)sharedInstance {
    static MessagingService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [MessagingService new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        BOOL _isMockMode = NO;
        
#if defined(SYSLAND_APP) || defined(USERLAND_APP)
#if SYSLAND_APP || USERLAND_APP
        _isMockMode = isMockMode();
#endif
#endif
        
        if (!_isMockMode) {
            [self configureMessagingQueue];
            [self configureDistributedMessagingCenter];
        }
    }
    
    return self;
}

- (void)registerForMessageName:(NSString *)name target:(id)target selector:(SEL)selector completion:(nonnull MessagingServiceRegisterCompletion)completion {
    __weak typeof(self) weakSelf = self;
    
    [self.messagingQueue addOperationWithBlock:^{
        [weakSelf.distributedMessagingCenter registerForMessageName:name target:target selector:selector];
        completion();
    }];
}

- (void)unregisterForMessageName:(NSString *)name completion:(nonnull MessagingServiceUnregisterCompletion)completion {
    __weak typeof(self) weakSelf = self;
    
    [self.messagingQueue addOperationWithBlock:^{
        [weakSelf.distributedMessagingCenter unregisterForMessageName:name];
        completion();
    }];
}

- (void)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary *)userInfo completion:(MessagingServiceSendMessageCompletion)completion {
    __weak typeof(self) weakSelf = self;
    
    [self.messagingQueue addOperationWithBlock:^{
        NSError * _Nullable error = nil;
        id _Nullable result = [weakSelf.distributedMessagingCenter sendMessageAndReceiveReplyName:name userInfo:userInfo error:&error];
        if (error) {
            NSLog(@"%@", error);
            completion(nil, error);
            return;
        }
        completion(result, nil);
    }];
}

- (void)configureMessagingQueue {
    NSOperationQueue *messagingQueue = [NSOperationQueue new];
    messagingQueue.qualityOfService = NSQualityOfServiceBackground;
    self.messagingQueue = messagingQueue;
}

- (void)configureDistributedMessagingCenter {
    CPDistributedMessagingCenter *distributedMessagingCenter = ((CPDistributedMessagingCenter * (*)(id, SEL, NSString *))objc_msgSend)(NSClassFromString(@"CPDistributedMessagingCenter"), @selector(centerNamed:), NamuTrackerIdentifierMessagingCenter);
    void *rocketbootstrap_dl_handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_NOW);
    void *rocketbootstrap_distributedmessagingcenter_apply_handle = dlsym(rocketbootstrap_dl_handle, "rocketbootstrap_distributedmessagingcenter_apply");
    ((void (*)(CPDistributedMessagingCenter *messaging_center))rocketbootstrap_distributedmessagingcenter_apply_handle)(distributedMessagingCenter);
    
    [self.messagingQueue addOperationWithBlock:^{
        [distributedMessagingCenter runServerOnCurrentThread];
    }];
    
    self.distributedMessagingCenter = distributedMessagingCenter;
}

@end
