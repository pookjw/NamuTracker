#import "HSAPIService.h"
#import "keys.h"
#import "HSAPIPreferenceService.h"

typedef NSString * BlizzardTokenAPI NS_STRING_ENUM;

static BlizzardTokenAPI const BlizzardTokenAPIBasePath = @"/oauth/token";
static BlizzardTokenAPI const BlizzardTokenAPIGrantTypeKey = @"grant_type";
static BlizzardTokenAPI const BlizzardTokenAPIGrantTypeValue = @"client_credentials";
static BlizzardTokenAPI const BlizzardTokenAPIAuthorizationKey = @"Authorization";

typedef NSString * BlizzardAPI NS_STRING_ENUM;

static BlizzardAPI const BlizzardAPIGetCardBasePath = @"/hearthstone/cards";
static BlizzardAPI const BlizzardAPIGetDeckBasePath = @"/hearthstone/deck";
static BlizzardAPI const BlizzardAPIAccessTokenKey = @"access_token";
static BlizzardAPI const BlizzardAPILocaleKey = @"locale";
static BlizzardAPI const BlizzardAPICodeKey = @"code";

@interface HSAPIService ()
@property (strong) HSAPIPreferenceService *hsAPIPreferenceService;
@end

@implementation HSAPIService

- (instancetype)init {
    if (self = [super init]) {
        [self configureHSAPIPreferenceService];
    }
    
    return self;
}

- (CancellableObject *)hsCardWithIdOrSlug:(NSString *)idOrSlug completion:(HSAPIServiceHSCardCompletion)completion {
    CancellableObject * _Nullable __block accessTokenCancellable = nil;
    CancellableObject * _Nullable __block hsCardCancellable = nil;
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [accessTokenCancellable cancel];
        [hsCardCancellable cancel];
    }];
    
    [self.hsAPIPreferenceService fetchRegionHostAndLocaleWithCompletion:^(HSAPIRegionHost regionHost, HSAPILocale  _Nonnull locale) {
        accessTokenCancellable = [self accessTokenWithRegionHost:regionHost WithCompletion:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
            if (error) {
                completion(nil, error);
                return;
            }

            NSURLComponents *components = [NSURLComponents new];

            components.scheme = @"https";
            components.host = NSStringForHSAPIFromRegionHost(regionHost);
            components.path = [NSString stringWithFormat:@"%@/%@", BlizzardAPIGetCardBasePath, idOrSlug];

            components.queryItems = @[
                [[NSURLQueryItem alloc] initWithName:BlizzardAPIAccessTokenKey value:accessToken],
                [[NSURLQueryItem alloc] initWithName:BlizzardAPILocaleKey value:locale]
            ];

            NSURL *url = components.URL;
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"GET";

            NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(nil, error);
                    return;
                }

                NSError * _Nullable parseError = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                if (parseError) {
                    completion(nil, parseError);
                    return;
                }

                HSCard *hsCard = [[HSCard alloc] initWithDictionary:dictionary];
                completion(hsCard, nil);
            }];

            hsCardCancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
                [task cancel];
            }];

            [task resume];
            [session finishTasksAndInvalidate];
        }];
    }];

    return cancellable;
}

- (CancellableObject *)hsDeckFromDeckCode:(NSString *)deckCode completion:(HSAPIServiceHSDeckCompletion)completion {
    CancellableObject * _Nullable __block accessTokenCancellable = nil;
    CancellableObject * _Nullable __block hsDeckCancellable = nil;
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [accessTokenCancellable cancel];
        [hsDeckCancellable cancel];
    }];
    
    [self.hsAPIPreferenceService fetchRegionHostAndLocaleWithCompletion:^(HSAPIRegionHost regionHost, HSAPILocale  _Nonnull locale) {
        accessTokenCancellable = [self accessTokenWithRegionHost:regionHost WithCompletion:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
            if (error) {
                completion(nil, error);
                return;
            }

            NSURLComponents *components = [NSURLComponents new];

            components.scheme = @"https";
            components.host = NSStringForHSAPIFromRegionHost(regionHost);
            components.path = BlizzardAPIGetDeckBasePath;

            components.queryItems = @[
                [[NSURLQueryItem alloc] initWithName:BlizzardAPIAccessTokenKey value: accessToken],
                [[NSURLQueryItem alloc] initWithName:BlizzardAPILocaleKey value:locale],
                [[NSURLQueryItem alloc] initWithName:BlizzardAPICodeKey value:deckCode]
            ];

            NSURL *url = components.URL;
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"GET";

            NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(nil, error);
                    return;
                }

                NSError * _Nullable parseError = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                if (parseError) {
                    completion(nil, parseError);
                    return;
                }

                HSDeck *hsDeck = [[HSDeck alloc] initWithDictionary:dictionary];
                completion(hsDeck, nil);
            }];

            hsDeckCancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
                [task cancel];
            }];

            [task resume];
            [session finishTasksAndInvalidate];
        }];
    }];
    
    return cancellable;
}

- (void)configureHSAPIPreferenceService {
    HSAPIPreferenceService *hsAPIPreferenceService = HSAPIPreferenceService.sharedInstance;
    self.hsAPIPreferenceService = hsAPIPreferenceService;
}

- (CancellableObject *)accessTokenWithRegionHost:(HSAPIRegionHost)regionHost WithCompletion:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))completion {
    NSURLComponents *components = [NSURLComponents new];
    
    components.scheme = @"https";
    components.host = NSStringForOAuthAPIFromRegionHost(regionHost);
    components.path = BlizzardTokenAPIBasePath;
    
    NSURLQueryItem *queryItem = [[NSURLQueryItem alloc] initWithName:BlizzardTokenAPIGrantTypeKey value: BlizzardTokenAPIGrantTypeValue];
    components.queryItems = @[queryItem];
    
    NSURL *url = components.URL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{
        BlizzardTokenAPIAuthorizationKey: NamuTrackerKeyBlizzardAuthorizationValue
    };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSError * _Nullable parseError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (parseError) {
            completion(nil, parseError);
            return;
        }
        
        NSString *accessToken = dictionary[@"access_token"];
        completion(accessToken, nil);
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
    
    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [task cancel];
    }];
    
    return cancellable;
}

@end
