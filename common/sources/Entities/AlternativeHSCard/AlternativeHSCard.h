//
//  AlternativeHSCard.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlternativeHSCard : NSManagedObject
@property (strong) NSString * _Nullable cardId;
@property (strong) NSNumber * _Nullable dbfId;
- (NSComparisonResult)compare:(AlternativeHSCard *)other;
- (void)synchronizeWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
