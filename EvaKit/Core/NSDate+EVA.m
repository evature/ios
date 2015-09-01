//
//  NSDate+EVA.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/25/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "NSDate+EVA.h"

@implementation NSDate (EVA)

+ (NSDateFormatter*)sharedFormatter {
    NSDateFormatter* formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-M-dd"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    }
    return formatter;
}

+ (instancetype)dateWithEvaString:(NSString*)evaString {
    return [[self sharedFormatter] dateFromString:evaString];
}

- (instancetype)dateByAddingDays:(NSInteger)days {
    return [self dateByAddingTimeInterval:(days*86400.0)];
}

- (instancetype)dateByAddingHours:(NSInteger)hours {
    return [self dateByAddingTimeInterval:(hours*3600.0)];
}

@end
