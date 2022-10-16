//
//  HSAPIPreferencesSectionModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import "HSAPIPreferencesSectionModel.h"
#import "LocalizableService.h"

@implementation HSAPIPreferencesSectionModel

- (instancetype)initWithType:(HSAPIPreferencesSectionModelType)type {
    if (self = [super init]) {
        self->_type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    HSAPIPreferencesSectionModel *other = (HSAPIPreferencesSectionModel *)object;
    
    if (![other isKindOfClass:[HSAPIPreferencesSectionModel class]]) {
        return NO;
    }
    
    return (self.type == other.type);
}

- (NSUInteger)hash {
    return self.type;
}

- (NSString *)headerText {
    switch (self.type) {
        case HSAPIPreferencesSectionModelTypeHSAPIRegionHosts:
            return [LocalizableService localizableForKey:LocalizableKeyServer];
        case HSAPIPreferencesSectionModelTypeHSAPILocales:
            return [LocalizableService localizableForKey:LocalizableKeyCardLanguage];
        default:
            return nil;
    }
}

- (NSString *)footerText {
    switch (self.type) {
        case HSAPIPreferencesSectionModelTypeHSAPIRegionHosts:
            return [LocalizableService localizableForKey:LocalizableKeyHsapiregionhostSectionFooter];
        default:
            return nil;
    }
}

@end
