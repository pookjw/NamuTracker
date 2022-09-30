#import "TrackingWindow.h"
#import "TrackingRootViewController.h"

@interface TrackingWindow ()
@property (strong) TrackingRootViewController *trackingRootViewController;
@property (weak) UIWindow * _Nullable boundsObservationWindow;
@property void *keyWindowBoundsObservationContext;
@end

@implementation TrackingWindow

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    if (self = [super initWithWindowScene:windowScene]) {
        [self setAttributes];
    }

    return self;
}

- (void)dealloc {
    [self.boundsObservationWindow removeObserver:self forKeyPath:@"bounds" context:self.keyWindowBoundsObservationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.keyWindowBoundsObservationContext == context) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self setCorrectFrame];
        }];
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
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
    // for passthrough touch, I don't use `-[UIWindow setRootViewContrller:]`
    [self addSubview:trackingRootViewController.view];
    trackingRootViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [trackingRootViewController.view.topAnchor constraintEqualToAnchor:self.topAnchor],
        [trackingRootViewController.view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [trackingRootViewController.view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [trackingRootViewController.view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    self.trackingRootViewController = trackingRootViewController;
    
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

    [self setCorrectFrame];
    [previousKeyWindow addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:self.keyWindowBoundsObservationContext];
    self.boundsObservationWindow = previousKeyWindow;

    [self makeKeyAndVisible];
    [previousKeyWindow makeKeyWindow];
}

- (void)setCorrectFrame {
    if (self.boundsObservationWindow == nil) return;

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;

    if ((orientation & UIDeviceOrientationLandscapeLeft) || (orientation & UIDeviceOrientationLandscapeRight)) {
        CGRect frame = self.boundsObservationWindow.frame;
        CGRect convertedFrame = CGRectMake(0.0f, 0.0f, frame.size.height, frame.size.width);
        self.frame = convertedFrame;
    } else {
        self.frame = self.boundsObservationWindow.frame;
    }
}

@end
