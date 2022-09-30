#import <Foundation/Foundation.h>

typedef NSString * NamuTrackerKey NS_STRING_ENUM;

/*
1. Generate API Client and generate credentials from https://develop.battle.net/access/clients
2. Generate Basic Authentication Header from https://www.blitter.se/utils/basic-authentication-header-generator/
3. Then you will get letters like `Basic @#!?@!$!!@$`. Paste it here. 
*/
static NamuTrackerKey const NamuTrackerKeyBlizzardAuthorizationValue = @"<#Blizzard Authentication Value#>";
