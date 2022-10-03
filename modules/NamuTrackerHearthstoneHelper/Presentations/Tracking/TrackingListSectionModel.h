#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TrackingListSectionModelType) {
    TrackingListSectionModelTypeCards
};

@interface TrackingListSectionModel : NSObject
@property (readonly) TrackingListSectionModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initCardsSection;
@end

NS_ASSUME_NONNULL_END
