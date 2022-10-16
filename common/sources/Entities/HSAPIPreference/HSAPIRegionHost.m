//
//  HSAPIRegionHost.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import "HSAPIRegionHost.h"

NSString *NSStringForHSAPIFromRegionHost(HSAPIRegionHost regionHost) {
    switch (regionHost) {
        case HSAPIRegionHostUS:
            return @"us.api.blizzard.com";
        case HSAPIRegionHostEU:
            return @"eu.api.blizzard.com";
        case HSAPIRegionHostKR:
            return @"kr.api.blizzard.com";
        case HSAPIRegionHostTW:
            return @"tw.api.blizzard.com";
        case HSAPIRegionHostCN:
            return @"gateway.battlenet.com.cn";
        default:
            return @"us.api.blizzard.com";
    }
}

NSString *NSStringForOAuthAPIFromRegionHost(HSAPIRegionHost regionHost) {
    switch (regionHost) {
        case HSAPIRegionHostUS:
            return @"us.battle.net";
        case HSAPIRegionHostEU:
            return @"eu.battle.net";
        case HSAPIRegionHostKR:
            return @"apac.battle.net";
        case HSAPIRegionHostTW:
            return @"apac.battle.net";
        case HSAPIRegionHostCN:
            return @"www.battlenet.com.cn";
        default:
            return @"us.battle.net";
    }
}

NSString *NSStringFromHSAPIRegionHost(HSAPIRegionHost regionHost) {
    switch (regionHost) {
        case HSAPIRegionHostUS:
            return @"HSAPIRegionHostUS";
        case HSAPIRegionHostEU:
            return @"HSAPIRegionHostEU";
        case HSAPIRegionHostKR:
            return @"HSAPIRegionHostKR";
        case HSAPIRegionHostTW:
            return @"HSAPIRegionHostTW";
        case HSAPIRegionHostCN:
            return @"HSAPIRegionHostCN";
        default:
            return @"unknown";
    }
}

NSSet<NSNumber *> *allHSAPIRegionHosts(void) {
    return [NSSet setWithArray:@[
        @(HSAPIRegionHostUS),
        @(HSAPIRegionHostEU),
        @(HSAPIRegionHostKR),
        @(HSAPIRegionHostTW),
        @(HSAPIRegionHostCN)
    ]];
}
