//
//  LocalDeck.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import <CoreData/CoreData.h>
#import "HSCard.h"
#import "HSDeck.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalDeck : NSManagedObject
@property (strong, getter=isSelected) NSNumber * _Nullable selected;
@property (strong) NSData * _Nullable hsCardsData;
@property (strong) NSString * _Nullable format;
@property (strong) NSNumber * _Nullable classId;
@property (strong) NSString * _Nullable deckCode;
@property (strong) NSString * _Nullable name;
@property (strong) NSNumber * _Nullable index;
@property (strong) NSDate * _Nullable timestamp;

@property (nonatomic) NSArray<HSCard *> *hsCards;
- (void)synchronizeWithHSDeck:(HSDeck *)hsDeck;
@end

NS_ASSUME_NONNULL_END
