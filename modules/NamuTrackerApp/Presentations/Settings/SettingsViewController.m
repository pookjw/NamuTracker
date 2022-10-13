//
//  SettingsViewController.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsViewController.h"
#import "SettingsViewModel.h"
#import "LocalizableService.h"
#import "DecksViewController.h"

@interface SettingsViewController () <UICollectionViewDelegate>
@property (strong) UICollectionView *collectionView;
@property (strong) SettingsViewModel *viewModel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureCollectionView];
    [self configureViewModel];
    [self bind];
}

- (void)setAttributes {
    self.title = [LocalizableService localizableForKey:LocalizableKeySettings];
}

- (void)configureCollectionView {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    listConfiguration.backgroundColor = UIColor.clearColor;
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.delegate = self;
    
    [self.view addSubview:collectionView];
    
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.collectionView = collectionView;
}

- (void)configureViewModel {
    SettingsViewModel *viewModel = [[SettingsViewModel alloc] initWithDataSource:[self dataSource]];
    self.viewModel = viewModel;
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedSelectedItemModelNotification:)
                                               name:NSNotificationNameSettingsViewModelSelectedItemModel
                                             object:self.viewModel];
}

- (SettingsDataSource *)dataSource {
    UICollectionViewCellRegistration *cellRegistration = [self cellRegistration];
    
    SettingsDataSource *dataSource = [[SettingsDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
        return cell;
    }];
    
    return dataSource;
}

- (UICollectionViewCellRegistration *)cellRegistration {
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        SettingsItemModel *itemModel = (SettingsItemModel *)item;
        if (![itemModel isKindOfClass:[SettingsItemModel class]]) return;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration cellConfiguration];
        contentConfiguration.text = itemModel.text;
        contentConfiguration.secondaryText = itemModel.secondaryText;
        contentConfiguration.image = itemModel.image;
        contentConfiguration.textProperties.numberOfLines = 0;
        contentConfiguration.secondaryTextProperties.numberOfLines = 0;
        
        cell.contentConfiguration = contentConfiguration;
        cell.accessories = itemModel.accessories;
        
        UIBackgroundConfiguration *backgroundConfiguration = [UIBackgroundConfiguration listGroupedCellConfiguration];
        backgroundConfiguration.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3f];

        cell.backgroundConfiguration = backgroundConfiguration;
    }];
    
    return cellRegistration;
}

- (void)receivedSelectedItemModelNotification:(NSNotification *)notification {
    SettingsItemModel * _Nullable itemModel = notification.userInfo[SettingsViewModelSelectedItemModelKey];
    if (itemModel == nil) return;
    
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        switch (itemModel.type) {
            case SettingsItemModelTypeDecks:
                [self presentDecksViewController];
                break;
            default:
                break;
        }
    }];
}

- (void)presentDecksViewController {
    DecksViewController *decksViewController = [DecksViewController new];
    
    if ((self.splitViewController) && (!self.splitViewController.isCollapsed)) {
        [self.splitViewController showDetailViewController:decksViewController sender:self];
    } else {
        [self.navigationController pushViewController:decksViewController animated:YES];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel handleSelectedIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel canHandleIndexPath:indexPath];
}

@end
