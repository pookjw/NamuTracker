#import "HSLogService.h"

@interface HSLogService ()
@end

@implementation HSLogService

+ (HSLogService *)sharedInstance {
    static HSLogService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [HSLogService new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        
    }

    return self;
}

- (void)configure {
    // assert(NO);
}

@end
