#import "TrackingListViewController.h"

@interface TrackingListViewController ()
@property (strong) UIVisualEffectView *blurView;
@property (strong) UICollectionView *collectionView;
@end

@implementation TrackingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
}

- (void)setAttributes {
    self.view.backgroundColor = UIColor.clearColor;
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerCurve = kCACornerCurveContinuous;
    self.view.layer.cornerRadius = 20.0f;

    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.view addSubview:blurView];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    self.blurView = blurView;

    //


}

@end
