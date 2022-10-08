#import "HSAPIService.h"
#import <NamuTracker/keys.h>

typedef NSString * BlizzardTokenAPI NS_STRING_ENUM;

static BlizzardTokenAPI const BlizzardTokenAPIHost = @"apac.battle.net"; // TODO: It's a South Korea server.
static BlizzardTokenAPI const BlizzardTokenAPIBasePath = @"/oauth/token";
static BlizzardTokenAPI const BlizzardTokenAPIGrantTypeKey = @"grant_type";
static BlizzardTokenAPI const BlizzardTokenAPIGrantTypeValue = @"client_credentials";
static BlizzardTokenAPI const BlizzardTokenAPIAuthorizationKey = @"Authorization";

typedef NSString * BlizzardAPI NS_STRING_ENUM;

static BlizzardAPI const BlizzardAPIAPIHost = @"kr.api.blizzard.com"; // TODO: It's a South Korea server.
static BlizzardAPI const BlizzardAPIGetCardBasePath = @"/hearthstone/cards";
static BlizzardAPI const BlizzardAPIGetDeckBasePath = @"/hearthstone/deck";
static BlizzardAPI const BlizzardAPIAccessTokenKey = @"access_token";
static BlizzardAPI const BlizzardAPILocaleKey = @"locale";
static BlizzardAPI const BlizzardAPICodeKey = @"code";

@implementation HSAPIService

- (CancellableObject *)hsCardWithIdOrSlug:(NSString *)idOrSlug completionHandler:(HSAPIServiceHSCardCompletionHandler)completionHandler {
    NSURLSessionTask * _Nullable __block curentTask = nil;

    curentTask = [self accessTokenWithCompletionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error){
        if (error) {
            completionHandler(nil, error);
            return;
        }

        NSURLComponents *components = [NSURLComponents new];

        components.scheme = @"https";
        components.host = BlizzardAPIAPIHost;
        components.path = [NSString stringWithFormat:@"%@/%@", BlizzardAPIGetCardBasePath, idOrSlug];

        components.queryItems = @[
            [[NSURLQueryItem alloc] initWithName:BlizzardAPIAccessTokenKey value:accessToken],
            [[NSURLQueryItem alloc] initWithName:BlizzardAPILocaleKey value:@"en_US"] // TODO
        ];

        NSURL *url = components.URL;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"GET";

        NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                completionHandler(nil, error);
                return;
            }

            NSError * _Nullable parseError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingTopLevelDictionaryAssumed error:&parseError];

            if (parseError) {
                completionHandler(nil, parseError);
                return;
            }

            HSCard *hsCard = [[HSCard alloc] initWithDictionary:dictionary];
            completionHandler(hsCard, nil);
        }];

        curentTask = task;

        [task resume];
        [session finishTasksAndInvalidate];
    }];

    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [curentTask cancel];
    }];

    return cancellable;
}

- (CancellableObject *)hsDeckFromDeckCode:(NSString *)deckCode completionHandler:(HSAPIServiceHSDeckCompletionHandler)completionHandler {
    NSURLSessionTask * _Nullable __block curentTask = nil;

    curentTask = [self accessTokenWithCompletionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error){
        if (error) {
            completionHandler(nil, error);
            return;
        }

        NSURLComponents *components = [NSURLComponents new];

        components.scheme = @"https";
        components.host = BlizzardAPIAPIHost;
        components.path = BlizzardAPIGetDeckBasePath;

        components.queryItems = @[
            [[NSURLQueryItem alloc] initWithName:BlizzardAPIAccessTokenKey value: accessToken],
            [[NSURLQueryItem alloc] initWithName:BlizzardAPILocaleKey value:@"en_US"], // TODO
            [[NSURLQueryItem alloc] initWithName:BlizzardAPICodeKey value:deckCode]
        ];

        NSURL *url = components.URL;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"GET";

        NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                completionHandler(nil, error);
                return;
            }

            NSError * _Nullable parseError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingTopLevelDictionaryAssumed error:&parseError];

            if (parseError) {
                completionHandler(nil, parseError);
                return;
            }

            HSDeck *hsDeck = [[HSDeck alloc] initWithDictionary:dictionary];
            completionHandler(hsDeck, nil);
        }];

        curentTask = task;

        [task resume];
        [session finishTasksAndInvalidate];
    }];

    CancellableObject *cancellable = [[CancellableObject alloc] initWithCancellationHandler:^{
        [curentTask cancel];
    }];

    return cancellable;
}

- (NSURLSessionTask *)accessTokenWithCompletionHandler:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))completionHandler {
    NSURLComponents *components = [NSURLComponents new];

    components.scheme = @"https";
    components.host = BlizzardTokenAPIHost;
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
            completionHandler(nil, error);
            return;
        }

        NSError * _Nullable parseError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingTopLevelDictionaryAssumed error:&parseError];

        if (parseError) {
            completionHandler(nil, parseError);
            return;
        }

        NSString *accessToken = dictionary[@"access_token"];
        completionHandler(accessToken, nil);
    }];

    [task resume];
    [session finishTasksAndInvalidate];

    return task;
}

@end
