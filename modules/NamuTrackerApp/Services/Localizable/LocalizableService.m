//
//  LocalizableService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import "LocalizableService.h"

@implementation LocalizableService

+ (NSString *)localizableForKey:(LocalizableKey)key {
    return NSLocalizedStringFromTable(key, @"Localizable", @"");
}

+ (NSString *)localizableForHSAPIRegionHost:(HSAPIRegionHost)hsAPIRegionHost {
    return NSLocalizedStringFromTable(NSStringFromHSAPIRegionHost(hsAPIRegionHost), @"HSAPIRegionHost", @"");
}

+ (NSString *)localizableForHSAPILocale:(HSAPILocale)hsAPILocale {
    return NSLocalizedStringFromTable(NSStringFromHSAPILocale(hsAPILocale), @"HSAPILocale", @"");
}

@end
