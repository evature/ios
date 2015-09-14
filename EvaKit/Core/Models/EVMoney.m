//
//  EVMoney.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVMoney.h"

@implementation EVMoney

static NSDictionary* restrictionKeys = nil;

+ (void)load {
    restrictionKeys = [@{@"Unknown": @(EVMoneyRestictionTypeUnknown),
                         @"Less": @(EVMoneyRestictionTypeLess),
                         @"More": @(EVMoneyRestictionTypeMore),
                         @"Least": @(EVMoneyRestictionTypeLeast),
                         @"Most": @(EVMoneyRestictionTypeMost),
                         @"Medium": @(EVMoneyRestictionTypeMedium),
                         } retain];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.amount = [response objectForKey:@"Amount"];
        self.currency = [response objectForKey:@"Currency"];
        self.perPerson = [response objectForKey:@"Per Person"] != nil ?[[response objectForKey:@"Per Person"] boolValue] : EVBoolNotSet;
        self.endOfRange = [response objectForKey:@"End Of Range"];
        if ([response objectForKey:@"Restriction"] != nil) {
            NSNumber* val = [restrictionKeys objectForKey:[response objectForKey:@"Restriction"]];
            if (val != nil) {
                self.restriction = [val shortValue];
            } else {
                self.restriction = EVMoneyRestictionTypeUnknown;
            }
        } else {
            self.restriction = EVMoneyRestictionTypeUnknown;
        }
    }
    return self;
}

- (void)dealloc {
    self.amount = nil;
    self.currency = nil;
    self.endOfRange = nil;
    [super dealloc];
}

@end
