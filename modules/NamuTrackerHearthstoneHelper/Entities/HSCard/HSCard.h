#import <Foundation/Foundation.h>

@interface HSCard : NSObject
@property (readonly) NSUInteger cardId;
@property (readonly) NSString *dbfId;
@property (readonly) NSString *name;
@property (readonly) NSInteger cost;
- (instancetype)initWithCardId:(NSUInteger)cardId
                         dbfId:(NSString *)dbfId
                          name:(NSString *)name
                          cost:(NSUInteger)cost;
@end