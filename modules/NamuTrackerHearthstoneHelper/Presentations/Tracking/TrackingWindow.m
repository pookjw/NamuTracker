#import "TrackingWindow.h"
#import "TrackingRootViewController.h"
#import "checkAvailability.h"

@interface TrackingWindow ()
@property (strong) TrackingRootViewController *trackingRootViewController;
@end

@implementation TrackingWindow

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    if (self = [super initWithWindowScene:windowScene]) {
        [self configureTrackingRootViewController];
        [self setAttributes];
    }

    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self.rootViewController.view pointInside:point withEvent:event];
}

- (void)present:(BOOL)animated {
    self.userInteractionEnabled = YES;

    __weak typeof(self) weakSelf = self;
    void (^changesHandler)() = ^{
         weakSelf.layer.opacity = 1.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            changesHandler();
        }];
    } else {
        changesHandler();
    }
}

- (void)dismiss:(BOOL)animated {
    self.userInteractionEnabled = NO;
    
    __weak typeof(self) weakSelf = self;
    void (^changesBlock)() = ^{
        weakSelf.alpha = 0.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            changesBlock();
        }];
    } else {
        changesBlock();
    }
}

- (void)configureTrackingRootViewController {
    TrackingRootViewController *trackingRootViewController = [TrackingRootViewController new];
    self.rootViewController = trackingRootViewController;
    self.trackingRootViewController = trackingRootViewController;
}

- (void)setAttributes {
    self.windowLevel = UIWindowLevelAlert;

    UIWindow * _Nullable __block previousKeyWindow = nil;
    
    if (checkAvailability(@"15.0")) {
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

    [self dismiss:NO];
}

@end
