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
        self.hello = EVBoolNotSet;
        self.yes = EVBoolNotSet;
        self.no = EVBoolNotSet;
        self.meaningOfLife = EVBoolNotSet;
        self.who = EVBoolNotSet;
        
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
            self.name = [response objectForKey:@"Name"];
        }
        self.newSession = [response objectForKey:@"New Session"] != nil ? [[response objectForKey:@"New Session"] boolValue] : EVBoolNotSet;
    }
    return self;
}

- (void)dealloc {
    self.name = nil;
    [super dealloc];
}

@end
