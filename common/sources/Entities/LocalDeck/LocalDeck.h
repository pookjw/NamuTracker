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
@property (assign) NSData * _Nullable hsCardsData;
@property (assign) NSString * _Nullable format;
@property (assign) NSNumber * _Nullable classId;
@property (assign) NSString * _Nullable deckCode;
@property (assign) NSString * _Nullable name;
@property (assign) NSDate * _Nullable timestamp;

@property (nonatomic) NSArray<HSCard *> *hsCards;
- (void)synchronizeWithHSDeck:(HSDeck *)hsDeck;
@end

NS_ASSUME_NONNULL_END
