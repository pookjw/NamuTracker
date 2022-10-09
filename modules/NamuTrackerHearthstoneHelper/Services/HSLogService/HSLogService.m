#import "HSLogService.h"
#import "CardService.h"
#import <NamuTracker/identifiers.h>

typedef NSString * HSLogServiceLogType NS_STRING_ENUM;
static HSLogServiceLogType const HSLogServiceLogTypeZone = @"Zone";
static HSLogServiceLogType const HSLogServiceLogTypeLoadingScreen = @"LoadingScreen";

@interface HSLogService ()
@property (strong) NSOperationQueue *timerQueue;
@property (strong) NSOperationQueue *workQueue;
@property (strong) NSTimer * _Nullable timer;
@property NSUInteger zoneLogCheckpoint;
@property NSUInteger loadingScreenLogCheckpoint;
@property (strong) CardService *cardService;
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

        NSOperationQueue *timerQueue = [NSOperationQueue new];
        timerQueue.qualityOfService = NSQualityOfServiceBackground;

        NSOperationQueue *workQueue = [NSOperationQueue new];
        workQueue.maxConcurrentOperationCount = 1;
        workQueue.qualityOfService = NSQualityOfServiceUtility;

        CardService *cardService = [CardService new];

        self.timerQueue = timerQueue;
        self.workQueue = workQueue;
        self.cardService = cardService;
    }

    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    [self.timerQueue cancelAllOperations];
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
    NSURL *logsURL = [documentURL URLByAppendingPathComponent:@"Logs"];

    [@[toURL, logsURL] enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSFileManager.defaultManager fileExistsAtPath:obj.path isDirectory:NULL]) {
            NSError * _Nullable error = nil;
            [NSFileManager.defaultManager removeItemAtURL:obj error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }];
    
    NSError * _Nullable error = nil;
    [NSFileManager.defaultManager copyItemAtURL:fromURL toURL:toURL error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }

    NSLog(@"Installed custom log configuration for hearthstone.");
}

- (void)startObserving {
    if (self.timer) {
        NSLog(@"Already observing. Ignored.");
        return;
    }

    __weak typeof(self) weakSelf = self;

    [self.timerQueue addOperationWithBlock:^{
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                          target:weakSelf
                                                        selector:@selector(triggeredTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
        
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            return;
        }
    }];
}

- (void)stopObserving {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)triggeredTimer:(NSTimer *)timer {
    if (!(timer.isValid)) {
        CFRunLoopStop(CFRunLoopGetCurrent());
    }

    __weak typeof(self) weakSelf = self;

    [self.workQueue addOperationWithBlock:^{
        if (weakSelf == nil) return;

        [weakSelf postNotificationForLogType:HSLogServiceLogTypeZone];
        [weakSelf postNotificationForLogType:HSLogServiceLogTypeLoadingScreen];
    }];
}

- (void)postNotificationForLogType:(HSLogServiceLogType)logType {
    NSArray<NSString *> *newLogStrings = [self newLogStringsForLogType:logType];

    if ([HSLogServiceLogTypeLoadingScreen isEqualToString:logType]) {
        [newLogStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:@"Gameplay.Unload()"]) {
                // TODO: Refactor
                self->_inGame = NO;
                [NSNotificationCenter.defaultCenter postNotificationName:HSLogServiceNotificationNameDidEndTheGame object:self userInfo:nil];
            } else if ([obj containsString:@"Gameplay.Start()"]) {
                // TODO: Refactor
                self->_inGame = YES;
                [NSNotificationCenter.defaultCenter postNotificationName:HSLogServiceNotificationNameDidStartTheGame object:self userInfo:nil];
            }
        }];
    } else if ([HSLogServiceLogTypeZone isEqualToString:logType]) {
        NSMutableArray<AlternativeHSCard *> *addedAlternativeHSCards = [NSMutableArray<AlternativeHSCard *> new];
        NSMutableArray<AlternativeHSCard *> *removedAlternativeHSCards = [NSMutableArray<AlternativeHSCard *> new];

        [newLogStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj containsString:@"ZoneChangeList.ProcessChanges() - processing"]) return;

            NSString * _Nullable __block zone = nil;
            NSString * _Nullable __block dstZoneTag = nil;
            NSString * _Nullable __block cardId = nil;

            NSArray<NSString *> *separatedStrings = [obj componentsSeparatedByString:@" "];
            [separatedStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray<NSString *> *keyValue = [obj componentsSeparatedByString:@"="];
                if (keyValue.count != 2) return;

                NSString *key = keyValue[0];
                NSString *value = keyValue[1];

                if ((key.length == 0) || (value.length == 0)) return;

                if ([key isEqualToString:@"zone"]) {
                    zone = value;
                } else if ([key isEqualToString:@"dstZoneTag"]) {
                    dstZoneTag = value;
                } else if ([key isEqualToString:@"cardId"]) {
                    cardId = value;
                }

                if ((zone) && (dstZoneTag) && (cardId)) {
                    *stop = YES;
                }
            }];

            if ((zone == nil) || (dstZoneTag == nil) || (cardId == nil)) {
                return;
            }

            //

            BOOL isValid = NO;
            BOOL didRemove = NO;

            if (([zone isEqualToString:@"HAND"]) && ([dstZoneTag containsString:@"DECK"])) {
                isValid = YES;
                didRemove = NO;
            } else if (([zone isEqualToString:@"DECK"]) && ([dstZoneTag containsString:@"HAND"])) {
                isValid = YES;
                didRemove = YES;
            }

            /*
            ZoneChangeList.ProcessChanges() - processing index=10 change=powerTask=[power=[type=TAG_CHANGE entity=[id=70 cardId=DMF_254t5 name=Body of C'Thun] tag=ZONE value=SETASIDE ] complete=False] entity=[entityName=Body of C'Thun id=70 zone=DECK zonePos=0 cardId=DMF_254t5 player=1] srcZoneTag=INVALID srcPos= dstZoneTag=SETASIDE dstPos=
            */

            //

            if (!isValid) return;

            AlternativeHSCard *alternativeHSCard = [self.cardService alternativeHSCardWithCardId:cardId];

            if (didRemove) {
                [removedAlternativeHSCards addObject:alternativeHSCard];
            } else {
                [addedAlternativeHSCards addObject:alternativeHSCard];
            }
        }];

        NSDictionary *userInfo = @{
            HSLogServiceAddedAlternativeHSCardsUserInfoKey: [addedAlternativeHSCards copy],
            HSLogServiceRemovedAlternativeHSCardsUserInfoKey: [removedAlternativeHSCards copy]
        };

        if ((addedAlternativeHSCards.count == 0) && (removedAlternativeHSCards.count == 0)) {
            return;
        }

        NSLog(@"%@", userInfo);
        
        [NSNotificationCenter.defaultCenter postNotificationName:HSLogServiceNotificationNameDidChangeCards object:self userInfo:userInfo];
    }
}

- (NSArray<NSString *> * _Nullable)newLogStringsForLogType:(HSLogServiceLogType)logType {
    NSURL *documentURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *logsURL = [documentURL URLByAppendingPathComponent:@"Logs"];
    NSURL *logURL = [[logsURL URLByAppendingPathComponent:logType] URLByAppendingPathExtension:@"log"];

    BOOL isLogURLDirectory = YES;
    BOOL doesLogURLExist = [NSFileManager.defaultManager fileExistsAtPath:logURL.path isDirectory:&isLogURLDirectory];

    if (isLogURLDirectory || !doesLogURLExist) {
        NSLog(@"%@ does not exist yet. Waiting...", logURL);
        return nil;
    }

    NSError * _Nullable error = nil;
    NSData *logData = [[NSData alloc] initWithContentsOfURL:logURL options:NSDataReadingUncached error:&error];
    
    if (error) {
        NSLog(@"An error occured: %@", error);
        return nil;
    }

    NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *logStrings = [logString componentsSeparatedByString:@"\n"];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *str,
                                                                   NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![str isEqualToString:@""];
    }];
    NSArray<NSString *> *filteredLogStrings = [logStrings filteredArrayUsingPredicate:predicate];

    NSUInteger location;

    if ([HSLogServiceLogTypeZone isEqualToString:logType]) {
        location = self.zoneLogCheckpoint;
        self.zoneLogCheckpoint = filteredLogStrings.count;
    } else if ([HSLogServiceLogTypeLoadingScreen isEqualToString:logType]) {
        location = self.loadingScreenLogCheckpoint;
        self.loadingScreenLogCheckpoint = filteredLogStrings.count;
    } else {
        NSLog(@"Unsupported logType: %@", logType);
        return nil;
    }

    NSUInteger length = filteredLogStrings.count - location;
    if (length == 0) {
        // no changes.
        return nil;
    } else if (length < 0) {
        NSLog(@"length is less than zero - this is an error.");
        return nil;
    }

    NSRange range = NSMakeRange(location, length);

    if (filteredLogStrings.count < location + length) {
        NSLog(@"out of range!");
        return nil;
    }
    
    NSArray<NSString *> *result = [filteredLogStrings subarrayWithRange:range];
    
    return result;
}

@end
