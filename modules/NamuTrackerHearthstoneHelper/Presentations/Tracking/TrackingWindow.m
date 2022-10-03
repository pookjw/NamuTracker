#import "TrackingWindow.h"
#import "TrackingRootViewController.h"

@interface TrackingWindow ()
@property (strong) TrackingRootViewController *trackingRootViewController;
@end

@implementation TrackingWindow

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    if (self = [super initWithWindowScene:windowScene]) {
        [self setAttributes];
    }

    return self;
}

- (void)present:(BOOL)animated {
    self.userInteractionEnabled = YES;

    __weak typeof(self) weakSelf = self;
    void (^block)() = ^{
         weakSelf.layer.opacity = 1.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            block();
        }];
    } else {
        block();
    }
}

- (void)dismiss:(BOOL)animated {
    self.userInteractionEnabled = NO;
    
    __weak typeof(self) weakSelf = self;
    void (^block)() = ^{
         weakSelf.layer.opacity = 0.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            block();
        }];
    } else {
        block();
    }
}

- (void)setAttributes {
    TrackingRootViewController *trackingRootViewController = [TrackingRootViewController new];
    self.rootViewController = trackingRootViewController;
    self.windowLevel = UIWindowLevelAlert;
    [self dismiss:NO];

    UIWindow * _Nullable __block previousKeyWindow = nil;
    
    if ([self.windowScene respondsToSelector:@selector(keyWindow)]) {
        // iOS 15.0+ - seems like @available does not work on theos environment...
        previousKeyWindow = self.windowScene.keyWindow;
    } else {
        [self.windowScene.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isKeyWindow) {
                previousKeyWindow = obj;
                *stop = YES;
            }
        }];
    }

    [self makeKeyAndVisible];
    [previousKeyWindow makeKeyWindow];
}

@end
