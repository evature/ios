//
//  EVSearchContext.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContext.h"
#import "EVCruiseSearchDelegate.h"
#import "EVHotelSearchDelegate.h"
#import "EVCarSearchDelegate.h"
#import "EVFlightSearchDelegate.h"

@implementation EVSearchContext

+ (instancetype)contextWithType:(EVSearchContextType)contextType {
    EVSearchContext *context = [[EVSearchContext new] autorelease];
    context->_type = contextType;
    return context;
}

+ (instancetype)contextForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(searchContext)]) {
        return [self contextWithType:[delegate searchContext]];
    }
    
    if ([delegate conformsToProtocol:@protocol(EVFlightSearchDelegate)]) {
        return [self contextWithType:EVSearchContextTypeFlight];
    } else if ([delegate conformsToProtocol:@protocol(EVCarSearchDelegate)]) {
        return [self contextWithType:EVSearchContextTypeCar];
    } else if ([delegate conformsToProtocol:@protocol(EVCruiseSearchDelegate)]) {
        return [self contextWithType:EVSearchContextTypeCruise];
    } else if ([delegate conformsToProtocol:@protocol(EVHotelSearchDelegate)]) {
        return [self contextWithType:EVSearchContextTypeHotel];
    }
    
    return [self contextWithType:0];
}

@end
