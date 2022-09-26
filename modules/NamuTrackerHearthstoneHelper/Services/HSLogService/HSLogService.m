#import "HSLogService.h"
#import <UIKit/UIKit.h>
#import <NamuTracker/identifiers.h>
#import <compareNullableValues.h>
#import "HSCard.h"

typedef NSString * HSLogServiceLogType NS_STRING_ENUM;
static HSLogServiceLogType const HSLogServiceLogTypeZone = @"Zone";
static HSLogServiceLogType const HSLogServiceLogTypeLoadingScreen = @"LoadingScreen";

@interface HSLogService ()
@property dispatch_queue_global_t timerQueue;
@property (strong) NSOperationQueue *workQueue;
@property (strong) NSTimer *timer;
@property NSUInteger lastZoneLogLocation;
@property NSUInteger lastLoadingScreenLocation;
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
    if (self = [super init]) {
        NSLog(@"Started HSLogService with %@", self);

        dispatch_queue_global_t timerQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);

        NSOperationQueue *workQueue = [NSOperationQueue new];
        workQueue.maxConcurrentOperationCount = 1;
        workQueue.qualityOfService = NSQualityOfServiceBackground;

        self.timerQueue = timerQueue;
        self.workQueue = workQueue;
    }

    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    [self.workQueue cancelAllOperations];
}

- (void)installCustomLogConfiguration {
    NSAssert([NSThread isMainThread], @"Should be run on Main Thread.");

    NSURL *fromURL = [[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLStringHearthstoneHelper] URLByAppendingPathComponent:@"log"] URLByAppendingPathExtension:@"config"];
    if (![NSFileManager.defaultManager fileExistsAtPath:fromURL.path isDirectory:NULL]) {
        NSLog(@"Not found: %@", NamuTrackerApplicationSupportURLStringHearthstoneHelper);
        return;
    }
    
    NSURL *documentURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *toURL = [[documentURL URLByAppendingPathComponent:@"log"] URLByAppendingPathExtension:@"config"];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:toURL.path isDirectory:NULL]) {
        NSError *error = nil;
        [NSFileManager.defaultManager removeItemAtURL:toURL error:&error];
        if (error) {
            NSLog(@"%@", error);
            return;
        }
    }
    
    NSError *error = nil;
    [NSFileManager.defaultManager copyItemAtURL:fromURL toURL:toURL error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }

    NSLog(@"Installed custom log configuration for hearthstone.");
}

- (void)startObserving {
    __weak typeof(self) weakSelf = self;
    
    // NSOperation doesn't have a valid NSRunLoop of unknown reason, but dispatch_queue does.
    dispatch_async(self.timerQueue, ^{
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                          target:weakSelf
                                                        selector:@selector(firedTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        [runLoop run];

        weakSelf.timer = timer;
    });
}

- (void)stopObserving {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)firedTimer:(NSTimer *)timer {
    [self.workQueue addOperationWithBlock:^{
        // [self postNotificationForLogType:HSLogServiceLogTypeZone];
        // [self postNotificationForLogType:HSLogServiceLogTypeLoadingScreen];
    }];
}

// - (void)postNotificationForLogType:(HSLogServiceLogType)logType {
//     NSArray<NSString *> *logStrings = [self logStringsForLogType:logType];

//     NSUInteger location;

//     if ([HSLogServiceLogTypeZone isEqualToString:logType]) {
//         location = self.lastZoneLogLocation;
//     } else if ([HSLogServiceLogTypeLoadingScreen isEqualToString:logType]) {
//         location = self.lastLoadingScreenLocation;
//     } else {
//         NSLog(@"Unsupported logType: %@", logType);
//         return;
//     }

//     NSUInteger length = logStrings.count - location;
//     if (length <= 0) return;

//     NSRange range = NSMakeRange(location, length);
//     NSArray<NSString *> *result = [logStrings subarrayWithRange:range];

//     NSNotificationName
// }

- (NSArray<NSString *> *)logStringsForLogType:(HSLogServiceLogType)logType {
    NSURL *documentURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *logsURL = [documentURL URLByAppendingPathComponent:@"Logs"];
    NSURL *logURL = [[logsURL URLByAppendingPathComponent:logType] URLByAppendingPathExtension:@"log"];
    NSData *logData = [NSData dataWithContentsOfURL:logURL];
    NSString *logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *logArr = [logStr componentsSeparatedByString:@"\n"];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *str,
                                                                   NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![str isEqualToString:@""];
    }];
    NSArray *filteredLogArr = [logArr filteredArrayUsingPredicate:predicate];

    return filteredLogArr;
}

@end
