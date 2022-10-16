//
//  HSAPIPreferencesViewController.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import "HSAPIPreferencesViewController.h"
#import "HSAPIPreferencesViewModel.h"
#import "LocalizableService.h"

@interface HSAPIPreferencesViewController () <UICollectionViewDelegate>
@property (strong) UICollectionView *collectionView;
@property (strong) HSAPIPreferencesViewModel *viewModel;
@end

@implementation HSAPIPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureCollectionView];
    [self configureViewModel];
}

- (void)setAttributes {
    self.title = [LocalizableService localizableForKey:LocalizableKeyServerAndCardLanguage];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
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
    HSAPIPreferencesViewModel *viewModel = [[HSAPIPreferencesViewModel alloc] initWithDataSource:[self createDataSource]];
    self.viewModel = viewModel;
}

- (HSAPIPreferencesDataSource *)createDataSource {
    UICollectionViewCellRegistration *cellRegistration = [self createCellRegistration];
    
    HSAPIPreferencesDataSource *dataSource = [[HSAPIPreferencesDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
        return cell;
    }];
    
    UICollectionViewSupplementaryRegistration *headerRegistration = [self createHeaderRegistration];
    UICollectionViewSupplementaryRegistration *footerRegistration = [self createFooterRegistration];
    
    dataSource.supplementaryViewProvider = ^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            return [collectionView dequeueConfiguredReusableSupplementaryViewWithRegistration:headerRegistration forIndexPath:indexPath];
        } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            return [collectionView dequeueConfiguredReusableSupplementaryViewWithRegistration:footerRegistration forIndexPath:indexPath];
        } else {
            return nil;
        }
    };
    
    return dataSource;
}

- (UICollectionViewCellRegistration *)createCellRegistration {
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        HSAPIPreferencesItemModel *itemModel = (HSAPIPreferencesItemModel *)item;
        if (![itemModel isKindOfClass:[HSAPIPreferencesItemModel class]]) return;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration cellConfiguration];
        contentConfiguration.text = itemModel.text;
        
        cell.contentConfiguration = contentConfiguration;
        
        if (itemModel.isSelected) {
            cell.accessories = @[[UICellAccessoryCheckmark new]];
        } else {
            cell.accessories = @[];
        }
        
        UIBackgroundConfiguration *backgroundConfiguration = [UIBackgroundConfiguration listGroupedCellConfiguration];
        backgroundConfiguration.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3f];

        cell.backgroundConfiguration = backgroundConfiguration;
    }];
    
    return cellRegistration;
}

- (UICollectionViewSupplementaryRegistration *)createHeaderRegistration {
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewSupplementaryRegistration *headerResgistration = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class]
                                                                                                                                       elementKind:UICollectionElementKindSectionHeader
                                                                                                                              configurationHandler:^(UICollectionViewListCell * _Nonnull supplementaryView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        HSAPIPreferencesSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
        NSString * _Nullable headerText = sectionModel.headerText;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration groupedHeaderConfiguration];
        contentConfiguration.text = headerText;
        
        supplementaryView.contentConfiguration = contentConfiguration;
    }];
    
    return headerResgistration;
}

- (UICollectionViewSupplementaryRegistration *)createFooterRegistration {
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewSupplementaryRegistration *footerRegistration = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class]
                                                                                                                                       elementKind:UICollectionElementKindSectionFooter
                                                                                                                              configurationHandler:^(UICollectionViewListCell * _Nonnull supplementaryView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        HSAPIPreferencesSectionModel * _Nullable sectionModel = [weakSelf.viewModel sectionModelForIndexPath:indexPath];
        NSString * _Nullable footerText = sectionModel.footerText;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration groupedFooterConfiguration];
        contentConfiguration.text = footerText;
        contentConfiguration.textProperties.alignment = UIListContentTextAlignmentCenter;
        
        supplementaryView.contentConfiguration = contentConfiguration;
    }];
    
    return footerRegistration;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.viewModel handleSelectedIndexPath:indexPath];
}

@end
