//
//  main.m
//  NamuTrackerAppResourcesScript
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <Foundation/Foundation.h>
#import "NSString+convertToCamelCase.h"

void createLocalizableKeys(void) {
    NSFileManager *fileManager = [NSFileManager new];
    NSURL *currentDirectoryURL = [NSURL fileURLWithPath:fileManager.currentDirectoryPath isDirectory:YES];
    NSURL *modulesURL = [currentDirectoryURL URLByAppendingPathComponent:@"modules" isDirectory:YES];
    NSURL *appURL = [modulesURL URLByAppendingPathComponent:@"NamuTrackerApp" isDirectory:YES];
    NSURL *localizableStringsURL = [[[[appURL URLByAppendingPathComponent:@"Resources" isDirectory:YES] URLByAppendingPathComponent:@"en.lproj" isDirectory:YES] URLByAppendingPathComponent:@"Localizable" isDirectory:NO] URLByAppendingPathExtension:@"strings"];
    NSURL *localizableKeyURL = [[[[appURL URLByAppendingPathComponent:@"Services" isDirectory:YES] URLByAppendingPathComponent:@"Localizable" isDirectory:YES] URLByAppendingPathComponent:@"LocalizableKey" isDirectory:NO] URLByAppendingPathExtension:@"h"];
    
    if (![fileManager fileExistsAtPath:appURL.path]) {
        [NSException raise:@"Not found." format:@"Please check current directory."];
    }
    
    if (![fileManager fileExistsAtPath:localizableStringsURL.path]) {
        [NSException raise:@"Not found." format:@"File is missing."];
    }
    
    //
    
    NSDictionary<NSString *, NSString *> *localizables = [NSDictionary dictionaryWithContentsOfURL:localizableStringsURL];
    NSArray<NSString *> *allKeys = localizables.allKeys;
    
    //
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    
    [result appendString:@"#import <Foundation/Foundation.h>\n\n"];
    [result appendString:@"typedef NSString * LocalizableKey NS_STRING_ENUM;\n\n"];
    
    [allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result appendString:[NSString stringWithFormat:@"static LocalizableKey const LocalizableKey%@ = @\"%@\";\n", [obj convertToCamelCase], obj]];
    }];
    
    //
    
    if ([fileManager fileExistsAtPath:localizableKeyURL.path]) {
        NSError * _Nullable error = nil;
        
        [fileManager removeItemAtURL:localizableKeyURL error:&error];
        
        if (error) {
            [NSException raise:@"An error occured. (4)" format:@"%@", error.localizedDescription];
        }
    }
    
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError * _Nullable error = nil;
    [data writeToURL:localizableKeyURL options:0 error:&error];
    
    if (error) {
        [NSException raise:@"An error occured. (5)" format:@"%@", error.localizedDescription];
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        createLocalizableKeys();
    }
    return 0;
}
