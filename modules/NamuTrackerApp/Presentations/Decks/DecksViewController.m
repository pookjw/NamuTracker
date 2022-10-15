//
//  DecksViewController.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "DecksViewController.h"
#import "LocalizableService.h"
#import "DecksViewModel.h"

@interface DecksViewController () <UICollectionViewDelegate, UITextFieldDelegate>
@property (strong) UICollectionView *collectionView;
@property (strong) DecksViewModel *viewModel;
@property (weak) UITextField * _Nullable deckNameTextField;
@property (weak) UITextField * _Nullable deckCodeTextField;
@property (weak) UIAlertAction * _Nullable fetchDeckCodeAlertAction;
@end

@implementation DecksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureRightBarButtonItems];
    [self configureCollectionView];
    [self configureViewModel];
}

- (void)setAttributes {
    self.title = [LocalizableService localizableForKey:LocalizableKeyDecks];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (void)configureRightBarButtonItems {
    __weak typeof(self) weakSelf = self;
    UIAction *addAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf presentAddNewDeckAlert];
    }];
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:addAction];
    addBarButtonItem.image = [UIImage systemImageNamed:@"plus"];
    
    self.navigationItem.rightBarButtonItems = @[addBarButtonItem];
}

- (void)configureCollectionView {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    listConfiguration.backgroundColor = UIColor.clearColor;
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
    DecksViewModel *viewModel = [[DecksViewModel alloc] initWithDataSource:[self createDataSource]];
    self.viewModel = viewModel;
}

- (DecksDataSource *)createDataSource {
    UICollectionViewCellRegistration *cellRegistration = [self createCellRegistration];
    
    DecksDataSource *dataSource = [[DecksDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
        return cell;
    }];
    
    UICollectionViewSupplementaryRegistration *footerRegistration = [self createFooterRegistration];
    
    dataSource.supplementaryViewProvider = ^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            return [collectionView dequeueConfiguredReusableSupplementaryViewWithRegistration:footerRegistration forIndexPath:indexPath];
        } else {
            return nil;
        }
    };
    
    return dataSource;
}

- (UICollectionViewCellRegistration *)createCellRegistration {
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        NSManagedObjectID *objectID = (NSManagedObjectID *)item;
        if (![objectID isKindOfClass:[NSManagedObjectID class]]) return;
        
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration cellConfiguration];
        NSMutableArray<UICellAccessory *> *accessories = [NSMutableArray<UICellAccessory *> new];
        
        LocalDeck * _Nullable localDeck = [weakSelf.viewModel localDeckFromIndexPath:indexPath];
        if (localDeck) {
            contentConfiguration.text = localDeck.name;
            
            if (localDeck.isSelected.boolValue) {
                [accessories addObject:[UICellAccessoryCheckmark new]];
            }
        }
        
        cell.contentConfiguration = contentConfiguration;
        cell.accessories = accessories;
        
        UIBackgroundConfiguration *backgroundConfiguration = [UIBackgroundConfiguration listGroupedCellConfiguration];
        backgroundConfiguration.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3f];

        cell.backgroundConfiguration = backgroundConfiguration;
    }];
    
    return cellRegistration;
}

- (UICollectionViewSupplementaryRegistration *)createFooterRegistration {
    UICollectionViewSupplementaryRegistration *headerRegistration = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class]
                                                                                                                                      elementKind:UICollectionElementKindSectionHeader
                                                                                                                             configurationHandler:^(UICollectionViewListCell * _Nonnull supplementaryView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration groupedFooterConfiguration];
        contentConfiguration.text = [LocalizableService localizableForKey:LocalizableKeyDecksFooterText];
        contentConfiguration.textProperties.alignment = UIListContentTextAlignmentCenter;
        
        supplementaryView.contentConfiguration = contentConfiguration;
    }];
    
    return headerRegistration;
}

- (void)presentAddNewDeckAlert {
    __weak typeof(self) weakSelf = self;
    
    [self.viewModel parseClipboardForDeckCodeWithCompletion:^(NSString * _Nullable name, NSString * _Nullable deckCode) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizableService localizableForKey:LocalizableKeyLoadFromDeckCode]
                                                                           message:[LocalizableService localizableForKey:LocalizableKeyPleaseEnterDeckCode]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            if (weakSelf == nil) return;
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = name;
                textField.placeholder = [LocalizableService localizableForKey:LocalizableKeyEnterDeckTitleHere];
                textField.delegate = weakSelf;
                weakSelf.deckNameTextField = textField;
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = deckCode;
                textField.placeholder = [LocalizableService localizableForKey:LocalizableKeyEnterDeckCodeHere];;
                textField.delegate = weakSelf;
                weakSelf.deckCodeTextField = textField;
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyCancel]
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *fetchDeckCodeAlertAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyFetch]
                                                                               style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * _Nonnull action) {
                NSString * _Nullable name = alert.textFields[0].text;
                NSString * _Nullable deckCode = alert.textFields[1].text;
                
                if ((deckCode == nil) || (deckCode.length == 0)) return;
                
                [weakSelf.viewModel addNewDeckFromDeckCode:deckCode name:name];
            }];
            weakSelf.fetchDeckCodeAlertAction = fetchDeckCodeAlertAction;
            
            [alert addAction:cancelAction];
            [alert addAction:fetchDeckCodeAlertAction];
            
            [weakSelf presentViewController:alert animated:YES completion:^{
                
            }];
        }];
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel setSelectedWithIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.deckCodeTextField]) {
        if (([string isEqualToString:@""]) && (textField.text.length == range.length)) {
            self.fetchDeckCodeAlertAction.enabled = NO;
        } else {
            self.fetchDeckCodeAlertAction.enabled = YES;
        }
    }
    return YES;
}

@end
