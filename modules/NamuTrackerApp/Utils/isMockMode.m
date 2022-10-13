//
//  isMockMode.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <Foundation/Foundation.h>

BOOL (^isMockMode)(void) = ^{
    NSArray<NSString *> *arguments = NSProcessInfo.processInfo.arguments;
    NSUInteger argIndex = [arguments indexOfObject:@"--mock-mode"];
    
    if (argIndex == NSNotFound) return NO;
    if (arguments.count <= (argIndex + 1)) return NO;
    
    NSString *stringValue = arguments[argIndex + 1];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    NSNumber *numberValue = [numberFormatter numberFromString:stringValue];
    BOOL result = (numberValue.unsignedIntegerValue != 0);
    
    return result;
};
