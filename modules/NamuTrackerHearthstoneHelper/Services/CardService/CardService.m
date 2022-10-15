#import "CardService.h"
#import "identifiers.h"
#import "HSAPIService.h"

@interface CardService ()
@property (strong) HSAPIService *hsAPIService;
@property (readonly, strong, nonatomic) NSDictionary *allCardsDictionary;
@end

@implementation CardService {
    NSDictionary * _allCardsDictionary;
}

@synthesize allCardsDictionary = _allCardsDictionary;

- (instancetype)init {
    if (self = [super init]) {
        [self configureHSAPIService];
    }

    return self;
}

- (AlternativeHSCard *)alternativeHSCardWithCardId:(NSString *)cardId {
    AlternativeHSCard * _Nullable __block result = nil;

    [self.allCardsDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop1) {
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop2) {
            NSDictionary *dictionary = (NSDictionary *)obj;

            if ([cardId isEqualToString:dictionary[@"cardId"]]) {
                AlternativeHSCard *alternativeHSCard = [[AlternativeHSCard alloc] initWithDictionary:dictionary];
                result = alternativeHSCard;
                *stop1 = YES;
                *stop2 = YES;
            }
        }];
    }];

    return result;
}

- (CancellableObject *)hsCardWithCardId:(NSString *)cardId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler {
    AlternativeHSCard *alternativeHSCard = [self alternativeHSCardWithCardId:cardId];
    return [self hsCardWithAlternativeHSCard:alternativeHSCard completionHandler:completionHandler];
}

- (CancellableObject *)hsCardWithDbfId:(NSUInteger)dbfId completionHandler:(CardServiceHSCardCompletionHandler)completionHandler {
    return [self.hsAPIService hsCardWithIdOrSlug:[@(dbfId) stringValue] completionHandler:completionHandler];
}

- (CancellableObject *)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completionHandler:(CardServiceHSCardCompletionHandler)completionHandler {
    return [self hsCardWithDbfId:alternativeHSCard.dbfId completionHandler:completionHandler];
}

- (CancellableObject *)hsCardsFromSelectedDeckWithCompletionHandler:(CardServiceHSCardsCompletionHandler)completionHandler {
    // TODO
    return [self.hsAPIService hsDeckFromDeckCode:NamuTrackerDemoDeckCode completionHandler:^(HSDeck * _Nullable hsDeck, NSError * _Nullable error) {
         completionHandler(hsDeck.hsCards, error);
    }];
}

- (NSDictionary *)allCardsDictionary {
    if (self->_allCardsDictionary) {
        return self->_allCardsDictionary;
    }

    NSURL *allCardsURL = [[[NSURL fileURLWithPath:NamuTrackerApplicationSupportURLString] URLByAppendingPathComponent:@"all_cards"] URLByAppendingPathExtension:@"json"];
    BOOL isDirectory = YES;
    BOOL doesExist = [NSFileManager.defaultManager fileExistsAtPath:allCardsURL.path isDirectory:&isDirectory];

    if (isDirectory || !doesExist) {
        NSLog(@"%@ does not exist - this is an error.", allCardsURL);
        return nil;
    }

    NSError * _Nullable error = nil;
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

- (void)configureHSAPIService {
    HSAPIService *hsAPIService = [HSAPIService new];
    self.hsAPIService = hsAPIService;
}

@end
