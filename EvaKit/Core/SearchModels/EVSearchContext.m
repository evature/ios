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
    if (contextType == EVSearchContextTypeNone) {
        return nil;
    }
    EVSearchContext *context = [[EVSearchContext new] autorelease];
    context->_type = contextType;
    return context;
}

+ (instancetype)contextForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(searchContext)]) {
        return [self contextWithType:[delegate searchContext]];
    }
    
    unsigned short protocolCount = 0;
    EVSearchContextType type = EVSearchContextTypeNone;
    
    if ([delegate conformsToProtocol:@protocol(EVFlightSearchDelegate)]) {
        protocolCount++;
        type = EVSearchContextTypeFlight;
    }
    if ([delegate conformsToProtocol:@protocol(EVCarSearchDelegate)]) {
        protocolCount++;
        type = EVSearchContextTypeCar;
        
    }
    if ([delegate conformsToProtocol:@protocol(EVCruiseSearchDelegate)]) {
        protocolCount++;
        type = EVSearchContextTypeCruise;
    }
    if ([delegate conformsToProtocol:@protocol(EVHotelSearchDelegate)]) {
        protocolCount++;
        type = EVSearchContextTypeHotel;
    }
    
    if (protocolCount > 1) {
        type = EVSearchContextTypeNone;
    }
    return [self contextWithType:type];
}

@end
