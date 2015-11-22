//
//  EVSearchContextBase.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContextBase.h"

@implementation EVSearchContextBase

@synthesize type = _type;

- (NSString*)requestParameterValue {
    NSMutableString* str = [NSMutableString string];
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeCar)) {
        [str appendString:@"c"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeFlight)) {
        [str appendString:@"f"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeHotel)) {
        [str appendString:@"h"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeCruise)) {
        [str appendString:@"r"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeVacation)) {
        [str appendString:@"v"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeSki)) {
        [str appendString:@"s"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeExplore)) {
        [str appendString:@"e"];
    }
    if (EV_CHECK_BITMASK(_type, EVSearchContextTypeCRM)) {
        [str appendString:@"m"];
    }
    return [NSString stringWithString:str];
}


@end
