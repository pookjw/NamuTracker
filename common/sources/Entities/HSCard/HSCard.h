#import <Foundation/Foundation.h>

#define HSCARD_LATEST_VERSION 0

NS_ASSUME_NONNULL_BEGIN

@interface HSCard : NSObject <NSCopying, NSCoding, NSSecureCoding>
@property (readonly) NSUInteger objectVersion;
@property (readonly, copy) NSNumber * _Nullable dbfId;
@property (readonly, copy) NSNumber * _Nullable collectible;
@property (readonly, copy) NSString * _Nullable slug;
@property (readonly, copy) NSNumber * _Nullable classId;
@property (readonly, copy) NSArray<NSNumber *> * _Nullable multiClassIds;
@property (readonly, copy) NSNumber * _Nullable minionTypeId;
@property (readonly, copy) NSNumber * _Nullable spellSchoolId;
@property (readonly, copy) NSNumber * _Nullable cardTypeId;
@property (readonly, copy) NSNumber * _Nullable cardSetId;
@property (readonly, copy) NSNumber * _Nullable rarityId;
@property (readonly, copy) NSString * _Nullable artistName;
@property (readonly, copy) NSNumber * _Nullable health;
@property (readonly, copy) NSNumber * _Nullable attack;
@property (readonly, copy) NSNumber * _Nullable manaCost;
@property (readonly, copy) NSString * _Nullable name;
@property (readonly, copy) NSString * _Nullable text;
@property (readonly, copy) NSURL * _Nullable image;
@property (readonly, copy) NSURL * _Nullable imageGold;
@property (readonly, copy) NSString * _Nullable flavorText;
@property (readonly, copy) NSURL * _Nullable cropImage;
@property (readonly, copy) NSArray<NSNumber *> * _Nullable childCardIds;
@property (readonly, copy) NSNumber * _Nullable parentCardId;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;
- (NSComparisonResult)compare:(HSCard *)other;
@end

NS_ASSUME_NONNULL_END
