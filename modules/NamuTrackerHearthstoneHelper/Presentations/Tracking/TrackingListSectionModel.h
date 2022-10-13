#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TrackingListSectionModelType) {
    TrackingListSectionModelTypeCards
};

@interface TrackingListSectionModel : NSObject
@property (readonly) TrackingListSectionModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(TrackingListSectionModelType)type NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
