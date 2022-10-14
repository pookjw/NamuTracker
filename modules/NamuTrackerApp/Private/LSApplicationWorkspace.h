//
//  LSApplicationWorkspace.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import <Foundation/Foundation.h>
#import "LSApplicationProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (NSArray<LSApplicationProxy *> *)allApplications;
@end

NS_ASSUME_NONNULL_END

