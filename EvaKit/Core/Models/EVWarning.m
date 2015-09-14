//
//  EVWarning.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVWarning.h"

@implementation EVWarning

- (instancetype)initWithResponse:(NSArray *)response {
    self = [super init];
    if (self != nil) {
        self.type = [response objectAtIndex:0];
        self.text = [response objectAtIndex:1];
        if ([self.type isEqualToString:@"Parse Warning"]) {
            NSDictionary* data = [response objectAtIndex:2];
            self.position = [[data objectForKey:@"position"] integerValue];
            self.text = [data objectForKey:@"text"];
        }
    }
    return self;
}

- (void)dealloc {
    self.type = nil;
    self.text = nil;
    [super dealloc];
}

@end
