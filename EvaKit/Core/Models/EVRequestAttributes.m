//
//  EVRequestAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVRequestAttributes.h"

@implementation EVRequestAttributes

static NSDictionary* sortKeys = nil;
static NSDictionary* orderKeys = nil;

+ (void)load {
    sortKeys = [@{@"reviews": @(EVRequestAttributesSortReviews),
                  @"location": @(EVRequestAttributesSortLocation),
                  @"price": @(EVRequestAttributesSortPrice),
                  @"price_per_person": @(EVRequestAttributesSortPricePerPerson),
                  @"distance": @(EVRequestAttributesSortDistance),
                  @"rating": @(EVRequestAttributesSortRating),
                  @"guest_rating": @(EVRequestAttributesSortGuestRating),
                  @"stars": @(EVRequestAttributesSortStars),
                  @"time": @(EVRequestAttributesSortTime),
                  @"total_time": @(EVRequestAttributesSortTotalTime),
                  @"duration": @(EVRequestAttributesSortDuration),
                  @"arrival_time": @(EVRequestAttributesSortArrivalTime),
                  @"departure_time": @(EVRequestAttributesSortDepartureTime),
                  @"outbound_arrival_time": @(EVRequestAttributesSortOutboundArrivalTime),
                  @"outbound_departure_time": @(EVRequestAttributesSortOutboundDepartureTime),
                  @"inbound_arrival_time": @(EVRequestAttributesSortInboundArrivalTime),
                  @"inbound_departure_time": @(EVRequestAttributesSortInboundDepartureTime),
                  @"airline": @(EVRequestAttributesSortAirline),
                  @"operator": @(EVRequestAttributesSortOperator),
                  @"cruiseline": @(EVRequestAttributesSortCruiseline),
                  @"cruiseship": @(EVRequestAttributesSortCruiseship),
                  @"name": @(EVRequestAttributesSortName),
                  @"popularity": @(EVRequestAttributesSortPopularity),
                  @"recommendations": @(EVRequestAttributesSortRecommendations)} retain];
    
    orderKeys = [@{@"ascending": @(EVRequestAttributesSortOrderAscending),
                   @"descending": @(EVRequestAttributesSortOrderDescending),
                   @"reverse": @(EVRequestAttributesSortOrderReverse)
                   } retain];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Transport Type"] != nil) {
            NSMutableArray* types = [NSMutableArray array];
            for (NSString* type in [response objectForKey:@"Transport Type"]) {
                [types addObject:type];
            }
            self.transportType = [NSArray arrayWithArray:types];
        }
        if ([response objectForKey:@"Sort"] != nil) {
            NSDictionary* sort = [response objectForKey:@"Sort"];
            if ([sort objectForKey:@"By"] != nil) {
                NSNumber* val = [sortKeys objectForKey:[[sort objectForKey:@"By"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                if (val != nil) {
                    self.sortBy = [val shortValue];
                } else {
                    self.sortBy = EVRequestAttributesSortUnknown;
                }
            } else {
                self.sortBy = EVRequestAttributesSortUnknown;
            }
            if ([sort objectForKey:@"Order"] != nil) {
                NSNumber* val = [orderKeys objectForKey:[[sort objectForKey:@"Order"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                if (val != nil) {
                    self.sortOrder = [val shortValue];
                } else {
                    self.sortOrder = EVRequestAttributesSortOrderUnknown;
                }
            } else {
                self.sortOrder = EVRequestAttributesSortOrderUnknown;
            }
        }
        
    }
    return self;
}

@end
