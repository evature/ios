//
//  EVSabre.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSabre.h"

@implementation EVSabre

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.cryptic = [response objectForKey:@"cryptic"];
        self.warnings = [response objectForKey:@"warnings"];
    }
    return self;
}

@end
