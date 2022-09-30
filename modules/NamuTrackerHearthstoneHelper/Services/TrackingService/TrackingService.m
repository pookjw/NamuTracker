#import "TrackingService.h"
#import <UIKit/UIKit.h>
#import "TrackingWindow.h"
#import "HSLogService.h"

@interface TrackingService ()
@property (strong) HSLogService *hsLogService;
@property (readonly, strong, nonatomic) TrackingWindow * _Nullable trackingWindow;
@end

@implementation TrackingService {
    TrackingWindow * _trackingWindow;
}

@synthesize trackingWindow = _trackingWindow;

+ (TrackingService *)sharedInstance {
    static TrackingService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [TrackingService new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        HSLogService *hsLogService = HSLogService.sharedInstance;
        self.hsLogService = hsLogService;
    }

    return self;
}

- (void)startObserving {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedDidStartTheGameNotification:) name:HSLogServiceNotificationNameDidStartTheGame object:self.hsLogService];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedDidEndTheGameNotification:) name:HSLogServiceNotificationNameDidEndTheGame object:self.hsLogService];
}

- (void)stopObserving {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (TrackingWindow *)trackingWindow {
    if (self->_trackingWindow) {
        return self->_trackingWindow;
    }

    UIWindowScene * _Nullable __block windowScene = nil;

    [UIApplication.sharedApplication.connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIWindowScene class]]) return;
        // if (obj.activationState != UISceneActivationStateForegroundActive) return;
        windowScene = (UIWindowScene *)obj;
    }];

    if (windowScene == nil) return nil;

    TrackingWindow *trackingWindow = [[TrackingWindow alloc] initWithWindowScene:windowScene];
    self->_trackingWindow = trackingWindow;
    return trackingWindow;
}

- (void)receivedDidStartTheGameNotification:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [weakSelf.trackingWindow present:YES];
    }];
}

- (void)receivedDidEndTheGameNotification:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [weakSelf.trackingWindow dismiss:YES];
    }];
}

@end
