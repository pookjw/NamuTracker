#import "TrackingRootViewController.h"
#import "PassthroughView.h"
#import "TrackingListViewController.h"
#import <checkAvailability.h>

@interface TrackingRootViewController ()
@property (strong) TrackingListViewController *trackingListViewController;
@property (strong) UIVisualEffectView *toggleButtonBlurView;
@property (strong) UIVisualEffectView *toggleButtonVibrancyView;
@property (strong) UIButton *toggleButton;
@property void *toggleButtonBlurViewBoundsObservationContext;
@property (weak) id<UIViewAnimating> _Nullable trackListViewAnimator;
@end

@implementation TrackingRootViewController

- (void)dealloc {
    [self.toggleButtonBlurView removeObserver:self forKeyPath:@"bounds" context:self.toggleButtonBlurViewBoundsObservationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == self.toggleButtonBlurViewBoundsObservationContext) {
        __weak UIVisualEffectView *weakObject = self.toggleButtonBlurView;
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            weakObject.layer.cornerRadius = weakObject.frame.size.height / 2.0f;
        }];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadView {
    self.view = [PassthroughView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self hideTrackingListView:NO];
}

- (void)setAttributes {
    self.view.backgroundColor = UIColor.clearColor;

    TrackingListViewController *trackingListViewController = [TrackingListViewController new];
    [self addChildViewController:trackingListViewController];

    [self.view addSubview:trackingListViewController.view];
    trackingListViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [trackingListViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8.0f],
        [trackingListViewController.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:8.0f],
        [trackingListViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8.0f],
        [trackingListViewController.view.widthAnchor constraintEqualToConstant:250.0f],
    ]];

    self.trackingListViewController = trackingListViewController;

    //
UIVisualEffectView *toggleButtonBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    toggleButtonBlurView.layer.masksToBounds = YES;
    toggleButtonBlurView.layer.cornerCurve = kCACornerCurveContinuous;
    [toggleButtonBlurView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:self.toggleButtonBlurViewBoundsObservationContext];
    
    [self.view addSubview:toggleButtonBlurView];
    toggleButtonBlurView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [toggleButtonBlurView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-8.0f],
        [toggleButtonBlurView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8.0f]
    ]];
    
    UIVisualEffectView *toggleButtonVibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *)toggleButtonBlurView.effect]];
    
    [toggleButtonBlurView.contentView addSubview:toggleButtonVibrancyView];
    toggleButtonVibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [toggleButtonVibrancyView.topAnchor constraintEqualToAnchor:toggleButtonBlurView.contentView.topAnchor],
        [toggleButtonVibrancyView.leadingAnchor constraintEqualToAnchor:toggleButtonBlurView.contentView.leadingAnchor],
        [toggleButtonVibrancyView.trailingAnchor constraintEqualToAnchor:toggleButtonBlurView.contentView.trailingAnchor],
        [toggleButtonVibrancyView.bottomAnchor constraintEqualToAnchor:toggleButtonBlurView.contentView.bottomAnchor]
    ]];
    
    //
    
    __weak typeof(self) weakSelf = self;
    UIAction *toggleButtonAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf toggleTrackingListView:YES];
    }];
    UIButton *toggleButton = [[UIButton alloc] initWithFrame:CGRectNull primaryAction:toggleButtonAction];
    
    if (checkAvailability(@"15.0")) {
        UIButtonConfiguration *toggleButtonConfiguration = [NSClassFromString(@"UIButtonConfiguration") plainButtonConfiguration];
        toggleButtonConfiguration.image = [UIImage systemImageNamed:@"list.bullet"];
        toggleButtonConfiguration.contentInsets = NSDirectionalEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
        
        UIBackgroundConfiguration *toggleBackgroundConfiguration = [NSClassFromString(@"UIBackgroundConfiguration") clearConfiguration];
        toggleButtonConfiguration.background = toggleBackgroundConfiguration;
        
        toggleButton.configuration = toggleButtonConfiguration;
    } else {
        [toggleButton setImage:[UIImage systemImageNamed:@"list.bullet"] forState:UIControlStateNormal];
        toggleButton.backgroundColor = [UIColor clearColor];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        toggleButton.contentEdgeInsets = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
#pragma clang diagnostic pop
    }
    
    [toggleButtonVibrancyView.contentView addSubview:toggleButton];
    toggleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [toggleButton.topAnchor constraintEqualToAnchor:toggleButtonVibrancyView.contentView.topAnchor],
        [toggleButton.leadingAnchor constraintEqualToAnchor:toggleButtonVibrancyView.contentView.leadingAnchor],
        [toggleButton.trailingAnchor constraintEqualToAnchor:toggleButtonVibrancyView.contentView.trailingAnchor],
        [toggleButton.bottomAnchor constraintEqualToAnchor:toggleButtonVibrancyView.contentView.bottomAnchor]
    ]];
    
    //
    
    self.toggleButtonBlurView = toggleButtonBlurView;
    self.toggleButtonVibrancyView = toggleButtonVibrancyView;
    self.toggleButton = toggleButton;
}

- (void)toggleTrackingListView:(BOOL)animated {
    if (self.trackingListViewController.view.alpha == 0.0f) {
        [self showTrackingListView:animated];
    } else {
        [self hideTrackingListView:animated];
    }
}

- (void)showTrackingListView:(BOOL)animated {
    self.trackingListViewController.view.hidden = NO;

    __weak UIView *weakObject = self.trackingListViewController.view;
    void (^changesHandler)() = ^{
         weakObject.layer.opacity = 1.0f;
    };
    void (^completionHandler)() = ^{
        weakObject.hidden = NO;
    };

    if (animated) {
        [self animateTrackingListView:changesHandler completionHandler:completionHandler];
    } else {
        changesHandler();
        completionHandler();
    }
}

- (void)hideTrackingListView:(BOOL)animated {
    __weak UIView *weakObject = self.trackingListViewController.view;
    void (^changesHandler)() = ^{
         weakObject.layer.opacity = 0.0f;
    };
    void (^completionHandler)() = ^{
        weakObject.hidden = YES;
    };

    if (animated) {
        [self animateTrackingListView:changesHandler completionHandler:completionHandler];
    } else {
        changesHandler();
        completionHandler();
    }
}

- (void)animateTrackingListView:(void (^)())changesHandler completionHandler:(void (^)())completionHandler {
    [self.trackListViewAnimator stopAnimation:YES];

    UIViewPropertyAnimator *trackListViewAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.2f curve:UIViewAnimationCurveEaseInOut animations:changesHandler];

    [trackListViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        completionHandler();
    }];

    [trackListViewAnimator startAnimation];

    self.trackListViewAnimator = trackListViewAnimator;
}

@end
