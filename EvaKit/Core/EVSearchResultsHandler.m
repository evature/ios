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
    
    
    //final Context context = activity;
    EVRequestAttributesSort sortBy = EVRequestAttributesSortUnknown;
    EVRequestAttributesSortOrder sortOrder = EVRequestAttributesSortOrderUnknown;

    if (response.requestAttributes != nil) {
        sortBy = response.requestAttributes.sortBy;
        sortOrder = response.requestAttributes.sortOrder;
    }
    
    BOOL nonstop;
    BOOL redeye;
    NSArray* airlines;
    EVFlightAttributesFoodType food;
    EVFlightAttributesSeatType seatType;
    NSArray* seatClass;
    
    if (response.flightAttributes == nil) {
        nonstop = NO;
        redeye = NO;
        airlines = nil;
        food = EVFlightAttributesFoodTypeUnknown;
        seatType = EVFlightAttributesSeatTypeUnknown;
        seatClass = nil;
    }
    else {
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
    
}

+ (void)handleHotelResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete location:(EVLocation*)location responseDelegate:(id<EVSearchDelegate>)delegate andMessageHandler:(void (^)(EVSearchModel* message, BOOL complete))handler {
    
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
