//
//  HSAPIRegionHost.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HSAPIRegionHost) {
    HSAPIRegionHostUS,
    HSAPIRegionHostEU,
    HSAPIRegionHostKR,
    HSAPIRegionHostTW,
    HSAPIRegionHostCN
};

NSString *NSStringForHSAPIFromRegionHost(HSAPIRegionHost);
NSString *NSStringForOAuthAPIFromRegionHost(HSAPIRegionHost);

/// For getting localizables.
NSString *NSStringFromHSAPIRegionHost(HSAPIRegionHost);

NSArray<NSNumber *> *allHSAPIRegionHosts(void);
