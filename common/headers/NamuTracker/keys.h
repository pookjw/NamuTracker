#import <Foundation/Foundation.h>

typedef NSString * NamuTrackerKey NS_STRING_ENUM;

/*
1. Generate API Client and generate credentials from https://develop.battle.net/access/clients
2. Generate Basic Authentication Header from https://www.blitter.se/utils/basic-authentication-header-generator/
3. Then you will get letters like `Basic abcdef12345`. Paste it here like:
    static NamuTrackerKey const NamuTrackerKeyBlizzardAuthorizationValue = @"Basic abcdef12345";
*/
static NamuTrackerKey const NamuTrackerKeyBlizzardAuthorizationValue = <#Blizzard Authentication Value#>;

/*
 1. Generate API Key from https://rapidapi.com/developer/apps
 2. Then you will get letters like `abcdef12345`. Paste it here like:
     static NamuTrackerKey const NamuTrackerKeyRapidAPIKey = @"abcdef12345";
 */
static NamuTrackerKey const NamuTrackerKeyRapidAPIKey = <#RapidAPI Key#>;
