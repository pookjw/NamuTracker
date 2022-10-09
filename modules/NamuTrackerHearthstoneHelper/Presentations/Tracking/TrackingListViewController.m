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
        if (checkAvailability(@"15.0")) {
            separatorConfiguration.visualEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] style:UIVibrancyEffectStyleSeparator];
        }
        layoutConfiguration.separatorConfiguration = separatorConfiguration;
    }
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:layoutConfiguration];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];

    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20.0f, 0.0f, 20.0f, 0.0f);

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
    TrackingListViewModel *viewModel = [[TrackingListViewModel alloc] initWithDataSource:[self dataSource]];
    self.viewModel = viewModel;
}

- (TrackingListDataSource *)dataSource {
    UICollectionViewCellRegistration *cellRegistration = [self cellRegistration];

    TrackingListDataSource *dataSource = [[TrackingListDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
        return cell;
    }];

    return dataSource;
}

- (UICollectionViewCellRegistration *)cellRegistration {
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(__kindof UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        if (![item isKindOfClass:[TrackingListItemModel class]]) return;

        TrackingListItemModel *itemModel = (TrackingListItemModel *)item;

        UIListContentConfiguration *configuration = [UIListContentConfiguration cellConfiguration];
        if (itemModel.hsCard) {
            configuration.text = [NSString stringWithFormat:@"(%@) %@ (x%@)", itemModel.hsCard.manaCost, itemModel.hsCard.name, itemModel.hsCardCount];
        } else {
            configuration.text = [NSString stringWithFormat:@"Loading: %@", itemModel.alternativeHSCard.cardId];
        }
        configuration.textProperties.color = UIColor.whiteColor;

        cell.contentConfiguration = configuration;

        UIBackgroundConfiguration *backgroundConfiguration = [UIBackgroundConfiguration listPlainCellConfiguration];
        backgroundConfiguration.backgroundColor = UIColor.clearColor;
        cell.backgroundConfiguration = backgroundConfiguration;
    }];

    return cellRegistration;
}

@end
