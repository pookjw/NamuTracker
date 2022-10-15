//
//  DecksViewModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LocalDeck.h"

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> DecksDataSource;

typedef void (^DecksViewModelParseClipboardCompletion)(NSString * _Nullable name, NSString * _Nullable deckCode);

@interface DecksViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(DecksDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
- (LocalDeck * _Nullable)localDeckFromIndexPath:(NSIndexPath *)indexPath;
- (void)parseClipboardForDeckCodeWithCompletion:(DecksViewModelParseClipboardCompletion)completion;
- (void)createLocalDeckFromDeckCode:(NSString *)deckCode name:(NSString * _Nullable)name;
- (void)setSelectedWithIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
