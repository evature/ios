//
//  EVServiceAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVServiceAttributes.h"

@implementation EVServiceAttributes

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.callSupportRequested = [[[response objectForKey:@"Call Support"] objectForKey:@"Requested"] boolValue];
    }
    return self;
}

@end
