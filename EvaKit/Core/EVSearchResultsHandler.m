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
#import "EVDataFlowElement.h"
#import "EVNavigateFlowElement.h"
#import "NSDate+EVA.h"
#import "EVFlightSearchModel.h"
#import "EVCruiseSearchModel.h"
#import "EVCRMDataSetModel.h"
#import "EVCRMDataGetModel.h"
#import "EVCRMNavigateModel.h"
#import "EVFlightNavigateModel.h"
#import "EVHotelSearchModel.h"


@interface EVSearchResultsHandler ()

+ (EVCallbackResult*)handleFlightResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to andResponseDelegate:(id<EVSearchDelegate>)delegate;

+ (EVCallbackResult*)handleCruiseResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to andResponseDelegate:(id<EVSearchDelegate>)delegate;

+ (EVCallbackResult*)handleHotelResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete location:(EVLocation*)location andResponseDelegate:(id<EVSearchDelegate>)delegate;

+ (EVCallbackResult*)handleDataWithResponse:(EVResponse*)response withFlow:(EVDataFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>) delegate;

+ (EVCallbackResult*)handleNavigateWithResponse:(EVResponse*)response  withFlow:(EVNavigateFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>)
delegate;

@end

@implementation EVSearchResultsHandler

+ (EVCallbackResult*)handleFlightResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to andResponseDelegate:(id<EVSearchDelegate>)delegate {
    BOOL oneWay = response.flightAttributes != nil && EV_IS_TRUE(response.flightAttributes.oneWay);
    
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
        return [model triggerSearchForDelegate:delegate];
    } else {
        // TODO: insert new chat item saying the app doesn't support flight search?
        EV_LOG_ERROR("App reached flight search, but has no matching handler");
    }
//    }
    return [EVCallbackResult resultWithNone];
}


+ (EVCallbackResult*)handleDataWithResponse:(EVResponse*)response withFlow:(EVDataFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>)
delegate {
    EVCallbackResult* cbR = [EVCallbackResult resultWithNone];
    if (flow.verb == EVDataFlowElementVerbTypeSet || flow.verb == EVDataFlowElementVerbTypeGet) {
        NSArray *pathArray = [flow.fieldPath componentsSeparatedByString:@"/"];
        if (![pathArray[0] isEqualToString:@"crm"]) {
            EV_LOG_ERROR(@"Expected path to start with CRM but was %@", flow.fieldPath);
            return cbR;
        }
        
        // expecting one of:
        //         crm/page/sub-page-id/field
        //         crm/page/field
        //         crm/field
        EVCRMPageType page = EVCRMPageTypeOther;
        NSString *field = [pathArray objectAtIndex:[pathArray count]-1];
        NSString *subPage = nil;
        NSUInteger count = [pathArray count];
        if (count > 2) {
            page = [EVCRMAttributes fieldPathToPageType:[pathArray objectAtIndex:1]];
        }
        if (count > 3) {
            subPage = [pathArray objectAtIndex:2];
        }
        
        if (flow.verb == EVDataFlowElementVerbTypeSet) {
            EVSearchModel* model = [EVCRMDataSetModel modelComplete:true
                                                             inPage:page
                                                            subPage:subPage
                                                           setField:field
                                                        ofValueType:flow.valueType
                                                            toValue:flow.value
                                    ];
            
            if ([delegate conformsToProtocol:@protocol(EVCRMDataSetDelegate)]) {
                cbR = [model triggerSearchForDelegate:delegate];
            }
            else {
                // TODO: insert new chat item saying the app doesn't support search?
                EV_LOG_ERROR(@"App reached crm data set, but has no matching handler");
            }
        }
        else {
            EVSearchModel* model = [EVCRMDataGetModel modelComplete:true
                                                             inPage:page
                                                            subPage:subPage
                                                           setField:field
                                    ];
            
            if ([delegate conformsToProtocol:@protocol(EVCRMDataGetDelegate)]) {
                cbR = [model triggerSearchForDelegate:delegate];
            }
            else {
                // TODO: insert new chat item saying the app doesn't support search?
                EV_LOG_ERROR(@"App reached crm data get, but has no matching handler");
            }

        }
    }
    return cbR;
}


+ (EVCallbackResult*)handleNavigateWithResponse:(EVResponse*)response  withFlow:(EVNavigateFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>)
    delegate {
    
    EVCallbackResult* cbR = [EVCallbackResult resultWithNone];
    NSArray *pathArray = [flow.pagePath componentsSeparatedByString:@"/"];
    NSUInteger count = [pathArray count];
    if (count < 2) {
        EV_LOG_ERROR(@"Expected path to be scope/page but was %@", flow.pagePath);
        return cbR;
    }
    if ([pathArray[0] isEqualToString:@"crm"]) {
        
        // expecting one of:
        //         crm/page/sub-page-id/field
        //         crm/page/field
        //         crm/field
        EVCRMPageType page = EVCRMPageTypeOther;
        NSString *subPage = nil;
        if (count > 2) {
            subPage = [pathArray objectAtIndex:2];
            page = [EVCRMAttributes fieldPathToPageType:[pathArray objectAtIndex:1]];
        }
        else if (count > 1) {
            page = [EVCRMAttributes stringToPageType:[pathArray objectAtIndex:1]];
        }

        
        
        EVSearchModel* model = [EVCRMNavigateModel  modelComplete:true
                                                           inPage:(EVCRMPageType)page
                                                          subPage:(NSString*)subPage
                                                    crmAttributes:response.crmAttributes];
        
        if ([delegate conformsToProtocol:@protocol(EVCRMNavigateDelegate)]) {
            return [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached crm navigate, but has no matching handler");
        }
    }
    else {
        // expecting
        //         flight/page

        EVFlightPageType  page = [EVFlightAttributes stringToPageType:[pathArray objectAtIndex:1]];
        EVSearchModel* model = [EVFlightNavigateModel  modelComplete:true
                                                           inPage:(EVFlightPageType)page];
        if ([delegate conformsToProtocol:@protocol(EVFlightNavigateDelegate)]) {
            return [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached flight navigate, but has no matching handler");
        }
    }
    return cbR;
}

+ (EVCallbackResult*)handleCruiseResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete fromLocation:(EVLocation*)from toLocation:(EVLocation*)to andResponseDelegate:(id<EVSearchDelegate>)delegate {
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
            return [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached hotel search, but has no matching handler");
        }
//    }
    return [EVCallbackResult resultWithNone];
}

+ (EVCallbackResult*)handleHotelResultsWithResponse:(EVResponse*)response isComplete:(BOOL)isComplete location:(EVLocation*)location andResponseDelegate:(id<EVSearchDelegate>)delegate {
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
            return [model triggerSearchForDelegate:delegate];
        }
        else {
            // TODO: insert new chat item saying the app doesn't support search?
            EV_LOG_ERROR(@"App reached hotel search, but has no matching handler");
        }
//    }
    return [EVCallbackResult resultWithNone];
}

+ (EVCallbackResult*)handleSearchResultWithResponse:(EVResponse*)response flow:(EVFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>)delegate {
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
                return [EVCallbackResult resultWithNone];
            }
            searchType = flow.type;
            from = flow.relatedLocations[0];
            to = flow.relatedLocations[1];
            isComplete = true;
            break;
            
        case EVFlowElementTypeHotel:
            if ([flow.relatedLocations count] < 1) {
                EV_LOG_INFO(@"Hotel search search without a location?");
                return [EVCallbackResult resultWithNone];
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
            
        case EVFlowElementTypeNavigate: {
            return [self handleNavigateWithResponse:response withFlow:(EVNavigateFlowElement*)flow  andResponseDelegate:delegate];
            break;
        }
        case EVFlowElementTypeData: {
            return [self handleDataWithResponse:response withFlow:(EVDataFlowElement*)flow andResponseDelegate:delegate];
            break;
        }
        default:
            break;
    }
    
    if (searchType == EVFlowElementTypeOther) {
        return [EVCallbackResult resultWithNone];
    }
    
    switch (searchType) {
        case EVFlowElementTypeCruise:
            return [self handleCruiseResultsWithResponse:response isComplete:isComplete fromLocation:from toLocation:to andResponseDelegate:delegate];
            break;
            
        case EVFlowElementTypeFlight:
            return [self handleFlightResultsWithResponse:response isComplete:isComplete fromLocation:from toLocation:to andResponseDelegate:delegate];
            break;
            
        case EVFlowElementTypeHotel:
            return [self handleHotelResultsWithResponse:response isComplete:isComplete location:from andResponseDelegate:delegate];
            break;
        
        default:
            break;
    }
    return [EVCallbackResult resultWithNone];
}

@end
