#import "TrackingRootViewController.h"
#import "PassthroughView.h"
#import "TrackingListViewController.h"

@interface TrackingRootViewController ()
@property (strong) TrackingListViewController *trackingListViewController;
@end

@implementation TrackingRootViewController

- (void)loadView {
    self.view = [PassthroughView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
}

- (void)setAttributes {
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f];

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
}

@end
