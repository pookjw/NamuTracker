#import <Foundation/Foundation.h>

#define ALTERNATIVEHSCARD_LATEST_VERSION 0

NS_ASSUME_NONNULL_BEGIN

@interface AlternativeHSCard : NSObject <NSCopying, NSCoding, NSSecureCoding>
@property (readonly) NSUInteger objectVersion;
@property (readonly, copy) NSString *cardId; // REV_018
@property (readonly) NSUInteger dbfId; // 79767
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;
- (NSComparisonResult)compare:(AlternativeHSCard *)other;
@end

NS_ASSUME_NONNULL_END
