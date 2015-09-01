//
//  EVTime.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVTime.h"

@implementation EVTime

- (NSInteger)daysDelta {
    NSInteger result = -1;
    if (self.delta != nil) {
        if ([self.delta hasPrefix:@"days=+"]) {
            result = [[self.delta substringFromIndex:6] integerValue];
        }
    }
    return result;
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
        self.calculated = [[response objectForKey:@"Calculated"] boolValue];
    }
    return self;
}

@end
