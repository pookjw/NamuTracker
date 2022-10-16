//
//  HSAPILocale.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import "HSAPILocale.h"

NSString *NSStringFromHSAPILocale(HSAPILocale apiLocale) {
    if ([HSAPILocaleEnUS isEqualToString:apiLocale]) {
        return @"HSAPILocaleEnUS";
    } else if ([HSAPILocaleFrFR isEqualToString:apiLocale]) {
        return @"HSAPILocaleFrFR";
    } else if ([HSAPILocaleDeDE isEqualToString:apiLocale]) {
        return @"HSAPILocaleDeDE";
    } else if ([HSAPILocaleItIT isEqualToString:apiLocale]) {
        return @"HSAPILocaleItIT";
    } else if ([HSAPILocaleJaJP isEqualToString:apiLocale]) {
        return @"HSAPILocaleJaJP";
    } else if ([HSAPILocaleKoKR isEqualToString:apiLocale]) {
        return @"HSAPILocaleKoKR";
    } else if ([HSAPILocalePlPL isEqualToString:apiLocale]) {
        return @"HSAPILocalePlPL";
    } else if ([HSAPILocaleRuRU isEqualToString:apiLocale]) {
        return @"HSAPILocaleRuRU";
    } else if ([HSAPILocaleZhCN isEqualToString:apiLocale]) {
        return @"HSAPILocaleZhCN";
    } else if ([HSAPILocaleEsES isEqualToString:apiLocale]) {
        return @"HSAPILocaleEsES";
    } else if ([HSAPILocaleEsMx isEqualToString:apiLocale]) {
        return @"HSAPILocaleEsMx";
    } else if ([HSAPILocaleZhTW isEqualToString:apiLocale]) {
        return @"HSAPILocaleZhTW";
    } else if ([HSAPILocalePtBR isEqualToString:apiLocale]) {
        return @"HSAPILocalePtBR";
    } else if ([HSAPILocaleThTH isEqualToString:apiLocale]) {
        return @"HSAPILocaleThTH";
    } else {
        return @"unknown";
    }
}

NSSet<HSAPILocale> *allHSAPILocales(void) {
    return [NSSet setWithArray:@[
        HSAPILocaleEnUS,
        HSAPILocaleFrFR,
        HSAPILocaleDeDE,
        HSAPILocaleItIT,
        HSAPILocaleJaJP,
        HSAPILocaleKoKR,
        HSAPILocalePlPL,
        HSAPILocaleRuRU,
        HSAPILocaleZhCN,
        HSAPILocaleEsES,
        HSAPILocaleEsMx,
        HSAPILocaleZhTW,
        HSAPILocalePtBR,
        HSAPILocaleThTH,
    ]];
}
