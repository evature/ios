//
//  EVTime.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVTime.h"

@implementation EVTime

+ (NSInteger)daysDelta:(NSString*)deltaString {
    NSInteger result = -1;
    if (deltaString != nil) {
        if ([deltaString hasPrefix:@"days=+"]) {
            result = [[deltaString substringFromIndex:6] integerValue];
        }
    }
    return result;
}

- (NSInteger)daysDelta {
    return [[self class] daysDelta:self.delta];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.date = [response objectForKey:@"Date"];
        self.time = [response objectForKey:@"Time"];
        self.restriction = [response objectForKey:@"Restriction"];
        self.delta = [response objectForKey:@"Delta"];
        self.minDelta = [response objectForKey:@"MinDelta"];
        self.maxDelta = [response objectForKey:@"MaxDelta"];
        self.calculated = [response objectForKey:@"Calculated"] != nil ? [[response objectForKey:@"Calculated"] boolValue] : EVBoolNotSet;
    }
    return self;
}

@end
