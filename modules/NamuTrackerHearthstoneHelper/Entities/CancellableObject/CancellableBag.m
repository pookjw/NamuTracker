#import "CancellableBag.h"

@interface CancellableBag ()
@property (strong) NSOperationQueue *queue;
@property (strong) NSMutableSet<CancellableObject *> *bag;
@end

@implementation CancellableBag

- (instancetype)init {
    if (self = [super init]) {
        [self configureQueue];
        [self configureBag];
    }

    return self;
}

- (void)addCancellable:(CancellableObject *)cancellable {
    [self.queue addOperationWithBlock:^{
        [self.bag addObject:cancellable];
    }];
}

- (void)removeCancellable:(CancellableObject *)cancellable {
    [self.queue addOperationWithBlock:^{
        [self.bag removeObject:cancellable];
    }];
}

- (void)removeAllCancellables {
    [self.queue addOperationWithBlock:^{
        [self.bag removeAllObjects];
    }];
}

- (void)configureQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    self.queue = queue;
}

- (void)configureBag {
    NSMutableSet<CancellableObject *> *bag = [NSMutableSet<CancellableObject *> new];
    self.bag = bag;
}

@end
