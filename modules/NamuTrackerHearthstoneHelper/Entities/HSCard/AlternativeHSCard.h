#import <Foundation/Foundation.h>

@interface AlternativeHSCard : NSObject <NSCopying, NSCoding, NSSecureCoding>
@property (readonly) NSUInteger objectVersion;
@property (readonly, copy) NSString *cardId; // REV_018
@property (readonly) NSUInteger dbfId; // 79767
@property (readonly, copy) NSString *name; // TODO: REMOVE // Prince Renathal
@property (readonly) NSInteger cost; // TODO: REMOVE // 3
- (instancetype)initWithCardId:(NSString *)cardId
                         dbfId:(NSUInteger)dbfId
                          name:(NSString *)name
                          cost:(NSUInteger)cost;
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;
@end