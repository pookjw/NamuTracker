#import <Foundation/Foundation.h>
#import "HSCard.h"

#define HSDECK_LATEST_VERSION 0

NS_ASSUME_NONNULL_BEGIN

@interface HSDeck : NSObject <NSCopying, NSCoding, NSSecureCoding>
@property (readonly) NSUInteger objectVersion;
@property (readonly, copy) NSString * _Nullable deckCode;
@property (readonly, copy) NSNumber * _Nullable version;
@property (readonly, copy) NSString * _Nullable format;
@property (readonly, copy) NSNumber * _Nullable classId;
@property (readonly, copy) NSArray<HSCard *> * _Nullable hsCards;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
