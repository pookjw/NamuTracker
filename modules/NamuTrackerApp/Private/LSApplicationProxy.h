//
//  LSApplicationProxy.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSApplicationProxy : NSObject
@property (readonly, nonatomic, getter=isInstalled) BOOL installed;
- (NSString *)un_applicationBundleIdentifier;
@end

NS_ASSUME_NONNULL_END
