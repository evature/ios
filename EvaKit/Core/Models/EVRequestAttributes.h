//
//  EVRequestAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int16_t, EVRequestAttributesSort) {
    EVRequestAttributesSortUnknown = -1,
    EVRequestAttributesSortReviews = 0,
    EVRequestAttributesSortLocation,
    EVRequestAttributesSortPrice,
    EVRequestAttributesSortPricePerPerson,
    EVRequestAttributesSortDistance,
    EVRequestAttributesSortRating,
    EVRequestAttributesSortGuestRating,
    EVRequestAttributesSortStars,
    EVRequestAttributesSortTime,
    EVRequestAttributesSortTotalTime,
    EVRequestAttributesSortDuration,
    EVRequestAttributesSortArrivalTime,
    EVRequestAttributesSortDepartureTime,
    EVRequestAttributesSortOutboundArrivalTime,
    EVRequestAttributesSortOutboundDepartureTime,
    EVRequestAttributesSortInboundArrivalTime,
    EVRequestAttributesSortInboundDepartureTime,
    EVRequestAttributesSortAirline,
    EVRequestAttributesSortOperator,
    EVRequestAttributesSortCruiseline,
    EVRequestAttributesSortCruiseship,
    EVRequestAttributesSortName,
    EVRequestAttributesSortPopularity,
    EVRequestAttributesSortRecommendations
};

typedef NS_ENUM(int16_t, EVRequestAttributesSortOrder) {
    EVRequestAttributesSortOrderUnknown = -1,
    EVRequestAttributesSortOrderAscending = 0,
    EVRequestAttributesSortOrderDescending,
    EVRequestAttributesSortOrderReverse
};

@interface EVRequestAttributes : NSObject

@property (nonatomic, strong, readwrite) NSArray* transportType;
@property (nonatomic, assign, readwrite) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readwrite) EVRequestAttributesSortOrder sortOrder;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
