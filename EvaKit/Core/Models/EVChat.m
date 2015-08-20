//
//  EVChat.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChat.h"

@implementation EVChat

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Hello"] != nil) {
            self.hello = [[response objectForKey:@"Hello"] boolValue];
        }
        if ([response objectForKey:@"Yes"] != nil) {
            self.yes = [[response objectForKey:@"Yes"] boolValue];
        }
        if ([response objectForKey:@"No"] != nil) {
            self.no = [[response objectForKey:@"No"] boolValue];
        }
        if ([response objectForKey:@"Meaning of Life"] != nil) {
            self.meaningOfLife = [[response objectForKey:@"Meaning of Life"] boolValue];
        }
        if ([response objectForKey:@"Who/What"] != nil) {
            self.who = [[response objectForKey:@"Who/What"] boolValue];
        }
        if ([response objectForKey:@"Name"] != nil) {
            self.name = [response objectForKey:@"Who/What"];
        }
        self.newSession = [[response objectForKey:@"New Session"] boolValue];
    }
    return self;
}

@end
