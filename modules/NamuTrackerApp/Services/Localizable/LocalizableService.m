//
//  LocalizableService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import "LocalizableService.h"

@implementation LocalizableService

+ (NSString *)localizableForKey:(LocalizableKey)key {
    return NSLocalizedString(key, @"");
}

@end
