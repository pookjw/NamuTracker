#import "CardService.h"
#import "identifiers.h"
#import "HSAPIService.h"
#import "LocalDeckService.h"
#import "AlternativeHSCardService.h"

@interface CardService ()
@property (strong) HSAPIService *hsAPIService;
@property (strong) LocalDeckService *localDeckService;
@property (strong) AlternativeHSCardService *alternativeHSCardService;
@end

@implementation CardService

- (instancetype)init {
    if (self = [super init]) {
        [self configureHSAPIService];
        [self configureLocalDeckService];
        [self configureAlternativeHSCardService];
    }

    return self;
}

- (void)alternativeHSCardWithCardId:(NSString *)cardId completion:(CardServiceAlternativeHSCardCompletion)completion {
    [self.alternativeHSCardService fetchAlternativeHSCardFromCardId:cardId completion:completion];
}

- (CancellableObject *)hsCardWithCardId:(NSString *)cardId completion:(CardServiceHSCardCompletion)completion {
    __block CancellableObject * _Nullable hsCardCancellable = nil;
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [hsCardCancellable cancel];
    }];

    [self alternativeHSCardWithCardId:cardId completion:^(AlternativeHSCard * _Nullable alternativeHSCard, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        if (!cancellable.isCancelled) {
            hsCardCancellable = [self hsCardWithAlternativeHSCard:alternativeHSCard completion:completion];
        }
    }];
    
    return cancellable;
}

- (CancellableObject *)hsCardWithDbfId:(NSNumber *)dbfId completion:(CardServiceHSCardCompletion)completion {
    return [self.hsAPIService hsCardWithIdOrSlug:[dbfId stringValue] completion:completion];
}

- (CancellableObject *)hsCardWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard completion:(CardServiceHSCardCompletion)completion{
    return [self hsCardWithDbfId:alternativeHSCard.dbfId completion:completion];
}

- (CancellableObject *)hsCardsFromSelectedDeckWithCompletion:(CardServiceHSCardsCompletion)completion {
    __block CancellableObject * _Nullable hsDeckCancellable;
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [hsDeckCancellable cancel];
    }];

    [self.localDeckService fetchSelectedLocalDeckWithCompletion:^(LocalDeck * _Nullable localDeck, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        hsDeckCancellable = [self.hsAPIService hsDeckFromDeckCode:localDeck.deckCode completion:^(HSDeck * _Nullable hsDeck, NSError * _Nullable error) {
            completion(hsDeck.hsCards, error);
        }];
    }];

    return cancellable;
}

- (void)configureHSAPIService {
    HSAPIService *hsAPIService = [HSAPIService new];
    self.hsAPIService = hsAPIService;
}

- (void)configureLocalDeckService {
    LocalDeckService *localDeckService = LocalDeckService.sharedInstance;
    self.localDeckService = localDeckService;
}

- (void)configureAlternativeHSCardService {
    AlternativeHSCardService *alternativeHSCardService = AlternativeHSCardService.sharedInstance;
    self.alternativeHSCardService = alternativeHSCardService;
}

@end
