//
//  EVPNRAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVPNRAttributes.h"

@implementation EVPNRAttributes

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.requested = [[response objectForKey:@"Requested"] boolValue];
    }
    return self;
}

@end
