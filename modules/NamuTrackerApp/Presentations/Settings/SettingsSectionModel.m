//
//  SettingsSectionModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsSectionModel.h"

@implementation SettingsSectionModel

- (instancetype)initWithType:(SettingsSectionModelType)type {
    if (self = [super init]) {
        self->_type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    SettingsSectionModel *other = (SettingsSectionModel *)object;
    
    if (![other isKindOfClass:[SettingsSectionModel class]]) {
        return NO;
    }
    
    if ((self.type == SettingsSectionModelTypeNotices) && (other.type == SettingsSectionModelTypeNotices)) {
        return YES;
    } else if ((self.type == SettingsSectionModelTypeNavigations) && (other.type == SettingsSectionModelTypeNavigations)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type;
}

@end
