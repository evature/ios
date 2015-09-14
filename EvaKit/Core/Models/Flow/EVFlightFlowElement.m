//
//  EVFlightFlowElement.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlightFlowElement.h"

@implementation EVFlightFlowElement

+ (void)load {
    [self registerClass:self forElementType:EVFlowElementTypeFlight];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        if ([response objectForKey:@"ReturnTrip"] != nil) {
            self.roundTripSayIt = [[response objectForKey:@"ReturnTrip"] objectForKey:@"SayIt"];
            self.actionIndex = [[[response objectForKey:@"ReturnTrip"] objectForKey:@"ActionIndex"] integerValue];
        }
    }
    return self;
}

- (NSString*)sayIt {
    if (self.roundTripSayIt != nil) {
        return self.roundTripSayIt;
    }
    return [super sayIt];
}

- (void)dealloc {
    self.roundTripSayIt = nil;
    [super dealloc];
}

@end
