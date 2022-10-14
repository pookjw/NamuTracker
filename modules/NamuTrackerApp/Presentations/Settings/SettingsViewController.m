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
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
}

- (void)configureCollectionView {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    listConfiguration.backgroundColor = UIColor.clearColor;
    listConfiguration.headerMode = UICollectionLayoutListHeaderModeSupplementary;
    listConfiguration.footerMode = UICollectionLayoutListFooterModeSupplementary;
    
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
    
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewSupplementaryRegistration *headerRegistration = [self headerRegistration];
    UICollectionViewSupplementaryRegistration *footerRegistration = [self footerRegistration];
    
    dataSource.supplementaryViewProvider = ^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            SettingsSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
//            if (sectionModel.headerText == nil) return nil;
            
            return [collectionView dequeueConfiguredReusableSupplementaryViewWithRegistration:headerRegistration forIndexPath:indexPath];
        } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            SettingsSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
//            if (sectionModel.footerText == nil) return nil;
            
            return [collectionView dequeueConfiguredReusableSupplementaryViewWithRegistration:footerRegistration forIndexPath:indexPath];
        } else {
            return nil;
        }
    };
    
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

- (UICollectionViewSupplementaryRegistration *)headerRegistration {
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewSupplementaryRegistration *headerResgistration = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class]
                                                                                                                                       elementKind:UICollectionElementKindSectionHeader
                                                                                                                              configurationHandler:^(UICollectionViewListCell * _Nonnull supplementaryView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        SettingsSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
        NSString * _Nullable headerText = sectionModel.headerText;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration groupedHeaderConfiguration];
        contentConfiguration.text = headerText;
        
        supplementaryView.contentConfiguration = contentConfiguration;
    }];
    
    return headerResgistration;
}

- (UICollectionViewSupplementaryRegistration *)footerRegistration {
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewSupplementaryRegistration *footerRegistration = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class]
                                                                                                                                       elementKind:UICollectionElementKindSectionFooter
                                                                                                                              configurationHandler:^(UICollectionViewListCell * _Nonnull supplementaryView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        SettingsSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
        NSString * _Nullable footerText = sectionModel.footerText;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration groupedHeaderConfiguration];
        contentConfiguration.text = footerText;
        contentConfiguration.textProperties.alignment = UIListContentTextAlignmentCenter;
        
        supplementaryView.contentConfiguration = contentConfiguration;
    }];
    
    return footerRegistration;
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
