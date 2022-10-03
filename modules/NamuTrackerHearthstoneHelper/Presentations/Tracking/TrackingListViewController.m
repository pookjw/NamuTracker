#import "TrackingListViewController.h"
#import <checkAvailability.h>
#import "TrackingListViewModel.h"

@interface TrackingListViewController ()
@property (strong) UIVisualEffectView *blurView;
@property (strong) UICollectionView *collectionView;
@property (strong) TrackingListViewModel *viewModel;
@end

@implementation TrackingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBlurView];
    [self configureCollectionView];
    [self setAttributes];
    [self configureViewModel];
}

- (void)configureBlurView {
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
}

- (void)configureCollectionView {
    UICollectionLayoutListConfiguration *layoutConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearancePlain];
    layoutConfiguration.backgroundColor = UIColor.clearColor;
    
    if (checkAvailability(@"14.5")) {
        UIListSeparatorConfiguration *separatorConfiguration = [[NSClassFromString(@"UIListSeparatorConfiguration") alloc] initWithListAppearance:UICollectionLayoutListAppearancePlain];
        separatorConfiguration.topSeparatorInsets = NSDirectionalEdgeInsetsZero;
        separatorConfiguration.bottomSeparatorInsets = NSDirectionalEdgeInsetsZero;
        separatorConfiguration.visualEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] style:UIVibrancyEffectStyleSeparator];
        layoutConfiguration.separatorConfiguration = separatorConfiguration;
    }
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:layoutConfiguration];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];
    [self.blurView.contentView addSubview:collectionView];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [collectionView.topAnchor constraintEqualToAnchor:self.blurView.contentView.topAnchor],
        [collectionView.leadingAnchor constraintEqualToAnchor:self.blurView.contentView.leadingAnchor],
        [collectionView.trailingAnchor constraintEqualToAnchor:self.blurView.contentView.trailingAnchor],
        [collectionView.bottomAnchor constraintEqualToAnchor:self.blurView.contentView.bottomAnchor]
    ]];

    self.collectionView = collectionView;
}

- (void)setAttributes {
    self.view.backgroundColor = UIColor.clearColor;
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerCurve = kCACornerCurveContinuous;
    self.view.layer.cornerRadius = 20.0f;
}

- (void)configureViewModel {
    TrackingListViewModel *viewModel = [[TrackingListViewModel alloc] init];
    self.viewModel = viewModel;
}

@end
