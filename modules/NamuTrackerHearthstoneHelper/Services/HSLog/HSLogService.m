#import "HSLogService.h"
#import "CardService.h"
#import "identifiers.h"

typedef NSString * HSLogServiceLogType NS_STRING_ENUM;
static HSLogServiceLogType const HSLogServiceLogTypeZone = @"Zone";
static HSLogServiceLogType const HSLogServiceLogTypeLoadingScreen = @"LoadingScreen";

@interface HSLogService ()
@property (strong) NSOperationQueue *timerQueue;
@property (strong) NSOperationQueue *backgroundQueue;
@property (strong) NSTimer * _Nullable timer;
@property CFRunLoopRef timerRunLoop;
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

        [self configureTimerQueue];
        [self configureBorkQueue];
        [self configureCardService];
    }

    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    [self.timerQueue cancelAllOperations];
    [self.backgroundQueue cancelAllOperations];
}

- (void)installCustomLogConfiguration {
    NSAssert([NSThread isMainThread], @"Should be run on Main Thread.");

    NSURL *fromURL = [[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:@"log"] URLByAppendingPathExtension:@"config"];
    if (![NSFileManager.defaultManager fileExistsAtPath:fromURL.path isDirectory:NULL]) {
        NSLog(@"Not found: %@", NamuTrackerApplicationSupportURLString);
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
        weakSelf.timerRunLoop = [runLoop getCFRunLoop];
        
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
    if (self.timerRunLoop) {
        CFRunLoopStop(self.timerRunLoop);
        self.timerRunLoop = NULL;
    }
}

- (void)configureTimerQueue {
    NSOperationQueue *timerQueue = [NSOperationQueue new];
    timerQueue.qualityOfService = NSQualityOfServiceBackground;
    self.timerQueue = timerQueue;
}

- (void)configureBorkQueue {
    NSOperationQueue *backgroundQueue = [NSOperationQueue new];
    backgroundQueue.maxConcurrentOperationCount = 1;
    backgroundQueue.qualityOfService = NSQualityOfServiceUtility;
    self.backgroundQueue = backgroundQueue;
}

- (void)configureCardService {
    CardService *cardService = [CardService new];
    self.cardService = cardService;
}

- (void)triggeredTimer:(NSTimer *)timer {
    if (!(timer.isValid) && (self.timerRunLoop)) {
        CFRunLoopStop(self.timerRunLoop);
    }

    __weak typeof(self) weakSelf = self;

    [self.backgroundQueue addOperationWithBlock:^{
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

            __block NSString * _Nullable type = nil;
            __block NSString * _Nullable zone = nil;
            __block NSString * _Nullable dstZoneTag = nil;
            __block NSString * _Nullable cardId = nil;

            __block NSString * _Nullable entityValue = nil;
            __block NSString * _Nullable metaType = nil;

            NSArray<NSString *> *separatedStrings = [obj componentsSeparatedByString:@" "];
            [separatedStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *filteredString = [[obj stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSArray<NSString *> *keyValue = [filteredString componentsSeparatedByString:@"="];
                if (keyValue.count < 2) return;

                NSString *key = keyValue[keyValue.count - 2];
                NSString *value = keyValue.lastObject;

                if ((key.length == 0) || (value.length == 0)) return;

                if ([key isEqualToString:@"type"]) {
                    type = value;
                } else if ([key isEqualToString:@"zone"]) {
                    zone = value;
                } else if ([key isEqualToString:@"dstZoneTag"]) {
                    dstZoneTag = value;
                } else if ([key isEqualToString:@"cardId"]) {
                    cardId = value;
                } else if ([key isEqualToString:@"value"]) {
                    entityValue = value;
                } else if ([key isEqualToString:@"metaType"]) {
                    metaType = value;
                }

                if ((zone) && (dstZoneTag) && (cardId)) {
                    *stop = YES;
                }
            }];

            if ((type == nil) || (zone == nil) || (dstZoneTag == nil) || (cardId == nil)) {
                return;
            }

            //

            NSLog(@"type: %@, zone: %@, dstZoneTag: %@, cardId: %@, entityValue: %@, metaType: %@", type, zone, dstZoneTag, cardId, entityValue, metaType);

            BOOL isValid = NO;
            BOOL didRemove = NO;
            
            if ([@"SHOW_ENTITY" isEqualToString:type]) {
                if (([@"DECK" isEqualToString:zone]) && (![@"DECK" isEqualToString:dstZoneTag])) {
                    // when draws a card (DECK / HAND), or burned (DECK / GRAVEYARD)
                    isValid = YES;
                    didRemove = YES;
                } else if ([@"DECK" isEqualToString:dstZoneTag]) {
                    // when put a card to deck.
                    isValid = YES;
                    didRemove = NO;
                }
            } else if ([@"HIDE_ENTITY" isEqualToString:type]) {
                if ((![@"DECK" isEqualToString:zone]) && ([@"DECK" isEqualToString:dstZoneTag])) {
                    // when exchange a card start of the game (HAND / DECK).
                    isValid = YES;
                    didRemove = NO;
                }
            } else if ([@"TAG_CHANGE" isEqualToString:type]) {
                if (([@"DECK" isEqualToString:zone]) && ([@"HAND" isEqualToString:dstZoneTag]) && [@"HAND" isEqualToString:entityValue]) {
                    // when draws dreged cards.
                    isValid = YES;
                    didRemove = YES;
                }
            } else if ([@"META_DATA" isEqualToString:type]) {
                if (([@"DECK" isEqualToString:zone]) && ([@"OVERRIDE_HISTORY" isEqualToString:metaType])) {
                    // C'Thun, the Shattered - remove from the deck start of the game.
                    isValid = YES;
                    didRemove = YES;
                } else if (([@"DECK" isEqualToString:zone]) && ([@"SLUSH_TIME" isEqualToString:metaType])) {
                    // Tradeable
                    isValid = YES;
                    didRemove = NO;
                } else if (([@"DECK" isEqualToString:zone]) && ([@"INVALID" isEqualToString:dstZoneTag]) && ([@"HISTORY_TARGET" isEqualToString:metaType])) {
                    // when drege a card, SHOW_ENTITY / DECK / DECK will occur, so have to remove it.
                    isValid = YES;
                    didRemove = YES;
                }
            }

            //

            if (!isValid) return;

            __block  AlternativeHSCard * _Nullable alternativeHSCard = nil;

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self.cardService alternativeHSCardWithCardId:cardId completion:^(AlternativeHSCard * _Nullable result, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                    dispatch_semaphore_signal(semaphore);
                    return;
                }

                alternativeHSCard = result;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

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
        // NSLog(@"%@ does not exist yet. Waiting...", logURL);
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
