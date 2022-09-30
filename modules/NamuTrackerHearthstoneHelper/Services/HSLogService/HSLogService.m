#import "HSLogService.h"
#import <UIKit/UIKit.h>
#import <NamuTracker/identifiers.h>
#import "AlternativeHSCard.h"

typedef NSString * HSLogServiceLogType NS_STRING_ENUM;
static HSLogServiceLogType const HSLogServiceLogTypeZone = @"Zone";
static HSLogServiceLogType const HSLogServiceLogTypeLoadingScreen = @"LoadingScreen";

@interface HSLogService ()
@property (strong) NSOperationQueue *timerQueue;
@property (strong) NSOperationQueue *workQueue;
@property (strong) NSTimer *timer;
@property NSUInteger zoneLogCheckpoint;
@property NSUInteger loadingScreenLogCheckpoint;
@property (readonly, nonatomic) NSDictionary *allCardsDictionary;
@end

@implementation HSLogService {
    NSDictionary *_allCardsDictionary;
}

@synthesize allCardsDictionary = _allCardsDictionary;

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

        self.timerQueue = timerQueue;
        self.workQueue = workQueue;
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
            NSError *error = nil;
            [NSFileManager.defaultManager removeItemAtURL:obj error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }];
    
    NSError *error = nil;
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

- (NSDictionary *)allCardsDictionary {
    if (self->_allCardsDictionary) {
        return self->_allCardsDictionary;
    }

    NSURL *allCardsURL = [[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLStringHearthstoneHelper] URLByAppendingPathComponent:@"all_cards"] URLByAppendingPathExtension:@"json"];
    BOOL isDirectory = YES;
    BOOL doesExist = [NSFileManager.defaultManager fileExistsAtPath:allCardsURL.path isDirectory:&isDirectory];

    if (isDirectory || !doesExist) {
        NSLog(@"%@ does not exist - this is an error.", allCardsURL);
        return nil;
    }

    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfURL:allCardsURL options:NSDataReadingUncached error:&error];
    if (error) {
        NSLog(@"An error occured: %@", error);
        return nil;
    }

    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingTopLevelDictionaryAssumed error:&error];
    
    if (error) {
        NSLog(@"An error occured: %@", error);
        return nil;
    }

    self->_allCardsDictionary = result;
    return result;
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
        if ([newLogStrings containsObject:@"[LoadingScreen] Gameplay.Unload()"]) {
            [NSNotificationCenter.defaultCenter postNotificationName:HSLogServiceNotificationNameDidEndTheGame object:self userInfo:nil];
        } else if ([newLogStrings containsObject:@"[LoadingScreen] Gameplay.Start()"]) {
            [NSNotificationCenter.defaultCenter postNotificationName:HSLogServiceNotificationNameDidStartTheGame object:self userInfo:nil];
        }
    } else if ([HSLogServiceLogTypeZone isEqualToString:logType]) {
        NSMutableArray<AlternativeHSCard *> *addedAlternativeHSCards = [NSMutableArray<AlternativeHSCard *> new];
        NSMutableArray<AlternativeHSCard *> *removedAlternativeHSCards = [NSMutableArray<AlternativeHSCard *> new];

        [newLogStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj containsString:@"ZoneChangeList.ProcessChanges()"]) return;

            BOOL found = NO;
            BOOL didRemove = NO;

            if (([obj containsString:@"zone=HAND"]) && ([obj containsString:@"dstZoneTag=DECK"])) {
                /*
                [Zone] ZoneChangeList.ProcessChanges() - processing index=7 change=powerTask=[power=[type=HIDE_ENTITY entity=[id=24 cardId=ICC_215 name=Archbishop Benedictus] zone=2] complete=False] entity=[entityName=Archbishop Benedictus id=24 zone=HAND zonePos=0 cardId=ICC_215 player=1] srcZoneTag=INVALID srcPos= dstZoneTag=DECK dstPos=
                */
                found = YES;
                didRemove = NO;
            } else if (([obj containsString:@"zone=DECK"]) && ([obj containsString:@"dstZoneTag=HAND"])) {
                /*
                [Zone] ZoneChangeList.ProcessChanges() - processing index=31 change=powerTask=[power=[type=TAG_CHANGE entity=[id=46 cardId= name=UNKNOWN ENTITY [cardType=INVALID]] tag=ZONE value=HAND ] complete=False] entity=[entityName=UNKNOWN ENTITY [cardType=INVALID] id=46 zone=DECK zonePos=0 cardId= player=2] srcZoneTag=INVALID srcPos= dstZoneTag=HAND dstPos=
                */
                found = YES;
                didRemove = YES;
            }

            if (!found) return;

            NSString * _Nullable __block cardId = nil;

            NSArray<NSString *> *array1 = [obj componentsSeparatedByString:@" "];
            [array1 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj containsString:@"cardId"]) {
                    NSArray<NSString *> *array2 = [obj componentsSeparatedByString:@"="];
                    if (array2.count >= 2) {
                        NSString * _Nullable _cardId = array2[1];
                        if (![_cardId isEqualToString:@""]) {
                            *stop = YES;
                            cardId = _cardId;
                        }
                    }
                }
            }];

            if (cardId == nil) return;

            [self.allCardsDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop1) {
                [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop2) {
                    NSDictionary *dictionary = (NSDictionary *)obj;

                    if ([cardId isEqualToString:dictionary[@"cardId"]]) {
                        AlternativeHSCard *alternativeHSCard = [AlternativeHSCard objectFromDictionary:dictionary];

                        if (didRemove) {
                            [removedAlternativeHSCards addObject:alternativeHSCard];
                        } else {
                            [addedAlternativeHSCards addObject:alternativeHSCard];
                        }
                        *stop1 = YES;
                        *stop2 = YES;
                    }
                }];
             }];

             NSLog(@"%@", obj);
        }];

        NSDictionary *userInfo = @{
            HSLogServiceAddedAlternativeHSCardsUserInfoKey: [addedAlternativeHSCards copy],
            HSLogServiceRemovedAlternativeHSCardsUserInfoKey: [removedAlternativeHSCards copy]
        };

        if ((addedAlternativeHSCards.count == 0) && (removedAlternativeHSCards.count == 0)) {
            return;
        }
        NSLog(@"%@ %@", addedAlternativeHSCards, removedAlternativeHSCards);
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

    NSError *error = nil;
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