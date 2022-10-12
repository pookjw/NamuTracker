#import "CancellableObject.h"

@interface CancellableObject ()
@property (copy) void (^cancellationHandler)(void);
@end

@implementation CancellableObject

- (instancetype)initWithCancellationHandler:(void (^)(void))cancellationHandler {
    if (self = [super init]) {
        self.cancellationHandler = cancellationHandler;
    }

    return self;
}

- (void)dealloc {
    [self cancel];
}

- (void)cancel {
    if (self.isCancelled) return;
    self.cancellationHandler();
    self->_isCancelled = YES;
}

@end