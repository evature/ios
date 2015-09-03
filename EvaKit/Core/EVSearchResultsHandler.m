//
//  EVSearchResultsHandler.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/25/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchResultsHandler.h"
#import "EVLocation.h"
#import "EVLogger.h"
#import "EVQuestionFlowElement.h"
#import "NSDate+EVA.h"
#import "EVFlightSearchModel.h"
#import "EVCruiseSearchModel.h"
#import "EVHotelSearchModel.h"


@interface EVSearchResultsHandler ()

+ (void)handleFlightResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler;

+ (void)handleCruiseResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler;

+ (void)handleHotelResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete location:(EVLocation*)location responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler;

@end

@implementation EVSearchResultsHandler

+ (void)handleFlightResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler {
    BOOL oneWay = response.flightAttributes != nil && response.flightAttributes.oneWay;
    
    NSDate* departDateMin = nil;
    NSDate* departDateMax = nil;
    NSString* departureStr = (from != nil && from.departure != nil) ? from.departure.date : nil;
    if (departureStr != nil) {
        departDateMin = [NSDate dateWithEvaString:departureStr];
        if (departDateMin != nil) {
            NSInteger days = [from.departure daysDelta];
            if (days != -1) {
                departDateMax = [departDateMin dateByAddingDays:days];
            }
        } else {
            EV_LOG_ERROR(@"Failed to parse eva departure date: %@", departureStr);
        }
    }
    
    NSDate* returnDateMin = nil;
    NSDate* returnDateMax = nil;
    
    if (!oneWay) {
        NSString* returnStr = (to != nil && to.departure != nil) ? to.departure.date : nil;
        if (returnStr == nil) {
            oneWay = true;
        } else {
            returnDateMin = [NSDate dateWithEvaString:returnStr];
            if (returnDateMin != nil) {
                NSInteger days = [to.departure daysDelta];
                if (days != -1) {
                    returnDateMax = [returnDateMin dateByAddingDays:days];
                }
            } else {
                EV_LOG_ERROR(@"Failed to parse eva return date: %@", returnStr);
            }
        }
    }
    
    EVRequestAttributesSort sortBy = EVRequestAttributesSortUnknown;
    EVRequestAttributesSortOrder sortOrder = EVRequestAttributesSortOrderUnknown;

    if (response.requestAttributes != nil) {
        sortBy = response.requestAttributes.sortBy;
        sortOrder = response.requestAttributes.sortOrder;
    }
    
    EVBool nonstop;
    EVBool redeye;
    NSArray* airlines;
    EVFlightAttributesFoodType food;
    EVFlightAttributesSeatType seatType;
    NSArray* seatClass;
    
    if (response.flightAttributes == nil) {
        nonstop = EVBoolNotSet;
        redeye = EVBoolNotSet;
        airlines = nil;
        food = EVFlightAttributesFoodTypeUnknown;
        seatType = EVFlightAttributesSeatTypeUnknown;
        seatClass = nil;
    } else {
        EVFlightAttributes* fa = response.flightAttributes;
        nonstop = fa.nonstop;
        redeye = fa.redeye;
        airlines = fa.airlines;
        food = fa.food;
        seatType = fa.seatType;
        seatClass = fa.seatClass;
    }
    EVFlightSearchModel* model = [EVFlightSearchModel modelComplete:isComplete
                                                             origin:from
                                                        destination:to
                                                      departDateMin:departDateMin
                                                      departDateMax:departDateMax
                                                      returnDateMin:returnDateMin
                                                      returnDateMax:returnDateMax
                                                          travelers:response.travelers
                                                            nonstop:nonstop
                                                             redeye:redeye
                                                             oneWay:oneWay
                                                           airlines:airlines
                                                               food:food
                                                           seatType:seatType
                                                        seatClasses:seatClass
                                                             sortBy:sortBy
                                                          sortOrder:sortOrder];
    handler(model, isComplete);
    
//    chatItem.setSearchModel(new AppFlightSearchModel(isComplete, from, to, departDateMin, departDateMax, returnDateMin, returnDateMax, reply.travelers,
//                                                     oneWay, nonstop, seatClass, airlines, redeye, food, seatType,
//                                                     sortBy, sortOrder));
//    
//    
//    
//    if (EvaComponent.evaAppHandler instanceof FlightCount) {
//        chatItem.setStatus(ChatItem.Status.SEARCHING);
//        chatItem.setSubLabel("Searching...");
//        mView.notifyDataChanged();
//        
//        AsyncCountResult flightCountHandler = new ResultsCountHandler(context, "One flight found.\nTap here to see it.",
//                                                                      " flights found.\nTap here to see them.",
//                                                                      activity.getString(R.string.evature_zero_count),
//                                                                      isComplete,
//                                                                      chatItem
//                                                                      );
//        
//        if (oneWay) {
//            ((FlightCount) EvaComponent.evaAppHandler).getOneWayFlightCount(context, isComplete, from, to,
//                                                                            departDateMin, departDateMax, returnDateMin, returnDateMax, reply.travelers,
//                                                                            nonstop, seatClass, airlines, redeye, food, seatType,
//                                                                            flightCountHandler);
//        }
//        else {
//            ((FlightCount) EvaComponent.evaAppHandler).getRoundTripFlightCount(context, isComplete, from, to,
//                                                                               departDateMin, departDateMax, returnDateMin, returnDateMax, reply.travelers,
//                                                                               nonstop, seatClass, airlines, redeye, food, seatType,
//                                                                               flightCountHandler);
//        }
//    }
//    else {
        // count is not supported - trigger search
    if ([delegate conformsToProtocol:@protocol(EVFlightSearchDelegate)]) {
        [model triggerSearchForDelegate:delegate];
    } else {
        // TODO: insert new chat item saying the app doesn't support flight search?
        EV_LOG_ERROR("App reached flight search, but has no matching handler");
    }
//    }
}

+ (void)handleCruiseResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler {
    NSDate *dateFrom = nil, *dateTo = nil;
    NSInteger durationFrom = -1, durationTo = -1;
    
    NSString *departure = (from != nil && from.departure != nil) ? from.departure.date : nil;
    if (departure != nil) {
        dateFrom = [NSDate dateWithEvaString:departure];
        if (dateFrom != nil) {
            NSInteger days = [from.departure daysDelta];
            if (days != -1) {
                dateTo = [dateFrom dateByAddingDays:days];
            }
        } else {
           EV_LOG_ERROR(@"Failed to parse eva departure date: %@", departure);
        }
    }
    
    if (to != nil && to.stay != nil) {
        if (to.stay.minDelta != nil && to.stay.maxDelta != nil) {
            durationFrom = [EVTime daysDelta:to.stay.minDelta];
            durationTo = [EVTime daysDelta:to.stay.maxDelta];
        } else {
            durationFrom = [to.stay daysDelta];
            durationTo = durationFrom;
        }
    }
    
    if (from != nil && from.nearestCustomerLocation != nil) {
        from = from.nearestCustomerLocation;
    }
    if (to != nil && to.nearestCustomerLocation != nil) {
        to = to.nearestCustomerLocation;
    }
    
    EVRequestAttributesSort sortBy = EVRequestAttributesSortUnknown;
    EVRequestAttributesSortOrder sortOrder = EVRequestAttributesSortOrderUnknown;
    
    if (response.requestAttributes != nil) {
        sortBy = response.requestAttributes.sortBy;
        sortOrder = response.requestAttributes.sortOrder;
    }
    
    EVSearchModel* model = [EVCruiseSearchModel modelComplete:isComplete fromLocation:from toLocation:to fromDate:dateFrom toDate:dateTo durationMin:durationFrom durationMax:durationTo cruiseAttributes:response.cruiseAttributes sortBy:sortBy sortOrder:sortOrder];
    
    handler(model, isComplete);
    
    
//    if (EvaComponent.evaAppHandler instanceof CruiseCount) {
//        
//        AsyncCountResult cruiseCountHandler = new ResultsCountHandler(activity, "One cruise found.\nTap here to see it.",
//                                                                      " cruises found.\nTap here to see them.",
//                                                                      activity.getString(R.string.evature_zero_count),
//                                                                      isComplete,
//                                                                      chatItem
//                                                                      );
//        
//        // count the results and update the chat item,  if there is only one result then activate search right away
//        ((CruiseCount) EvaComponent.evaAppHandler).getCruiseCount(activity, from, to, dateFrom, dateTo, durationFrom, durationTo, reply.cruiseAttributes,
//                                                                  cruiseCountHandler);
//    }
//    else {
        // count is not supported - trigger search
        if ([delegate conformsToProtocol:@protocol(EVCruiseSearchDelegate)]) {
            [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached hotel search, but has no matching handler");
        }
//    }
}

+ (void)handleHotelResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete location:(EVLocation*)location responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler {
    NSDate *arriveDateMin = nil;
    NSDate *arriveDateMax = nil;
    NSString *arrivalStr = (location != nil && location.arrival != nil) ? location.arrival.date : nil;
    if (arrivalStr != nil) {
        arriveDateMin = [NSDate dateWithEvaString:arrivalStr];
        if (arriveDateMin != nil) {
            NSInteger days = [location.arrival daysDelta];
            if (days != -1) {
                arriveDateMax = [arriveDateMin dateByAddingDays:days];
            }
        } else {
            EV_LOG_ERROR(@"Failed to parse eva arrival date: %@", arrivalStr);
        }
    }
    
    NSInteger durationMin = -1, durationMax = -1;
    if (location != nil && location.stay != nil) {
        if (location.stay.minDelta != nil && location.stay.maxDelta != nil) {
            durationMin = [EVTime daysDelta:location.stay.minDelta];
            durationMax = [EVTime daysDelta:location.stay.maxDelta];
        } else {
            durationMin = [location.stay daysDelta];
            durationMax = durationMin;
        }
    }
    
    
    EVRequestAttributesSort sortBy = EVRequestAttributesSortUnknown;
    EVRequestAttributesSortOrder sortOrder = EVRequestAttributesSortOrderUnknown;

    if (response.requestAttributes != nil) {
        sortBy = response.requestAttributes.sortBy;
        sortOrder = response.requestAttributes.sortOrder;
    }
    
    NSArray* chains = [NSArray array];
    // The hotel board:
    EVBool selfCatering = EVBoolNotSet;
    EVBool bedAndBreakfast = EVBoolNotSet;
    EVBool halfBoard = EVBoolNotSet;
    EVBool fullBoard = EVBoolNotSet;
    EVBool allInclusive = EVBoolNotSet;
    EVBool drinksInclusive = EVBoolNotSet;
    
    // The quality of the hotel, measure in Stars
    NSInteger minStars = -1;
    NSInteger maxStars = -1;
    
    NSSet* amenities = [NSSet set];
    
    if (response.hotelAttributes != nil) {
        EVHotelAttributes* ha = response.hotelAttributes;
        selfCatering = ha.selfCatering;
        bedAndBreakfast = ha.bedAndBreakfast;
        halfBoard = ha.halfBoard;
        fullBoard = ha.fullBoard;
        allInclusive = ha.allInclusive;
        drinksInclusive = ha.drinksInclusive;
        
        chains = ha.chains;
        minStars = ha.minStars;
        maxStars = ha.maxStars;
        amenities = ha.amenities;
    }
    
    if (location.hotelAttributes != nil) {
        EVHotelAttributes* ha = location.hotelAttributes;
        if (EV_IS_BOOL_SET(ha.selfCatering)) {
            selfCatering = ha.selfCatering;
        }
        if (EV_IS_BOOL_SET(ha.bedAndBreakfast)) {
            bedAndBreakfast = ha.bedAndBreakfast;
        }
        if (EV_IS_BOOL_SET(ha.halfBoard)) {
            halfBoard = ha.halfBoard;
        }
        if (EV_IS_BOOL_SET(ha.fullBoard)) {
            fullBoard = ha.fullBoard;
        }
        if (EV_IS_BOOL_SET(ha.allInclusive)) {
            allInclusive = ha.allInclusive;
        }
        if (EV_IS_BOOL_SET(ha.drinksInclusive)) {
            drinksInclusive = ha.drinksInclusive;
        }
        if ([ha.chains count] > 0) {
            chains = ha.chains;
        }
        if (ha.minStars != -1) {
            minStars = ha.minStars;
        }
        if (ha.maxStars != -1) {
            maxStars = ha.maxStars;
        }
        if ([ha.amenities count] > 0) {
            amenities = ha.amenities;
        }
        
    }
    
    EVSearchModel *model = [EVHotelSearchModel modelComplete:isComplete location:location arriveDateMin:arriveDateMin arriveDateMax:arriveDateMax durationMin:durationMin durationMax:durationMax travelers:response.travelers hotelsChain:chains selfCatering:selfCatering bedAndBreakfast:bedAndBreakfast halfBoard:halfBoard fullBoard:fullBoard allInclusive:allInclusive drinksInclusive:drinksInclusive minStars:minStars maxStars:maxStars amenities:amenities sortBy:sortBy sortOrder:sortOrder];
    
    handler(model, isComplete);
    
//    if (EvaComponent.evaAppHandler instanceof HotelCount) {
//        chatItem.setStatus(ChatItem.Status.SEARCHING);
//        chatItem.setSubLabel("Searching...");
//        mView.notifyDataChanged();
//        
//        AsyncCountResult hotelCountHandler = new ResultsCountHandler(context, "One hotel found.\nTap here to see it.",
//                                                                     " hotels found.\nTap here to see them.",
//                                                                     activity.getString(R.string.evature_zero_count),
//                                                                     isComplete,
//                                                                     chatItem
//                                                                     );
//        
//        
//        ((HotelCount) EvaComponent.evaAppHandler).getHotelCount(context, isComplete, location,
//                                                                arriveDateMin, arriveDateMax,
//                                                                durationMin, durationMax,
//                                                                reply.travelers,
//                                                                chains,
//                                                                
//                                                                // The hotel board:
//                                                                selfCatering, bedAndBreakfast, halfBoard, fullBoard, allInclusive, drinksInclusive,
//                                                                
//                                                                // The quality of the hotel, measure in Stars
//                                                                minStars, maxStars,
//                                                                
//                                                                amenities,
//                                                                hotelCountHandler);
//        
//    }
//    else {
        // count is not supported - trigger search
        if ([delegate conformsToProtocol:@protocol(EVHotelSearchDelegate)]) {
            [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached hotel search, but has no matching handler");
        }
//    }
}

+ (void)handleSearchResultWithResponse:(EVResponse*)response flow:(EVFlowElement*)flow responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler {
    EVLocation* from = nil;
    EVLocation* to = nil;
    EVFlowElementType searchType = EVFlowElementTypeOther;
    BOOL isComplete = NO;
    switch (flow.type) {
        case EVFlowElementTypeCruise:
        case EVFlowElementTypeFlight:
        case EVFlowElementTypeCar:
            if ([flow.relatedLocations count] < 2) {
                EV_LOG_INFO(@"Search without two locations?");
                handler(nil, isComplete);
                return;
            }
            searchType = flow.type;
            from = flow.relatedLocations[0];
            to = flow.relatedLocations[1];
            isComplete = true;
            break;
            
        case EVFlowElementTypeHotel:
            if ([flow.relatedLocations count] < 1) {
                EV_LOG_INFO(@"Hotel search search without a location?");
                handler(nil, isComplete);
                return;
            }
            searchType = flow.type;
            from = flow.relatedLocations[0];
            isComplete = true;
            break;
            
        case EVFlowElementTypeQuestion: {
            EVQuestionFlowElement* qe = (EVQuestionFlowElement*)flow;
            searchType = qe.actionType;
            // cruises have (for now) only origin and destination
            if ([response.locations count] > 0) {
                from = response.locations[0];
            }
            if ([response.locations count] > 1) {
                to = response.locations[1];
            }
            isComplete = false;
            break;
        }
        default:
            break;
    }
    
    if (searchType == EVFlowElementTypeOther) {
        return;
    }
    
    switch (searchType) {
        case EVFlowElementTypeCruise:
            [self handleCruiseResultsWithResponse:response isComplete:isComplete fromLocation:from toLocation:to responseDelegate:delegate andMessageHandler:handler];
            break;
            
        case EVFlowElementTypeFlight:
            [self handleFlightResultsWithResponse:response isComplete:isComplete fromLocation:from toLocation:to responseDelegate:delegate andMessageHandler:handler];
            break;
            
        case EVFlowElementTypeHotel:
            [self handleHotelResultsWithResponse:response isComplete:isComplete location:from responseDelegate:delegate andMessageHandler:handler];
            break;
        default:
            break;
    }
}

@end
