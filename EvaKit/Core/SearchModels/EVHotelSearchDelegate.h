//
//  EVHotelSearchDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVHotelAttributes.h"
#import "EVRequestAttributes.h"
#import "EVLocation.h"
#import "EVTravelers.h"

@protocol EVHotelSearchDelegate <EVSearchDelegate>


/*****
  handleHotelSearchWhichComplete - callback when Eva collects criteria to search for hotels
 
    isComplete - true if Eva considers the search flow "complete", ie. all the mandatory criteria have been requested by the user
    location - The location where the hotel is requested, properties of interest are:
        location.name - name of location
        location.allAirportsCode, location.airports - IATA codes of nearby airports
        location.geoId - geoname id
        location.latitude, longitude - GPS coordinates
    
    arriveDateMin - the date the user requested to check in to the hotel
    arriveDateMax - in case the user specified a range of dates (eg. "I want a hotel sometime in August")  this is the max of the range, nil otherwise.
    durationMin - the number of nights the user requested to stay at the hotel
    durationMax - in case the user specified a range of stay duration (eg. "I want to stay three to six nights")  this is the max of the range, nil otherwise
    checkoutDate - simple (arriveDateMin + durationMin) -  in case you want a checkout date instead of stay duration
 
    travelers - the people for which the hotel is booked
    hotelChain - array of EVHotelChain

    minStars, maxStars -  a range of Stars requested  (eg. "4 star hotels" would have min=max=4,  "at least 4 star" would be min=4,max=5)
 
    filters - to avoid cluttering the delegate with rarely used filters, these are placed in a dictionary. See below the possible keys/values.
        If a key does not exist in the dictionary, it means it wasn't specified by the user.
        Possible filters keys:
            selfCatering, bedAndBreakfast, halfBoard, fullBoard, allInclusive, drinksInclusive - booleans
            parkingFacilities, parkingValet, parkingFree - booleans
            pool - EVHotelAttributesPoolType
            accommodationType - EVHotelAttributesAccommodationType
            amenities - a set of EVHotelAttributesAmentities enums

    sortBy, sortOrder - the requested sorting requested
 ********/
- (EVCallbackResult*)handleHotelSearchWhichComplete:(BOOL)isComplete
                                           location:(EVLocation*)location
                                      arriveDateMin:(NSDate*)arriveDateMin
                                      arriveDateMax:(NSDate*)arriveDateMax
                                        durationMin:(NSInteger)durationMin
                                        durationMax:(NSInteger)durationMax
                                       checkoutDate:(NSDate*)checkoutDate
                                          travelers:(EVTravelers*)travelers
                                         attributes:(EVHotelAttributes*)attributes
                                             sortBy:(EVRequestAttributesSort)sortBy
                                          sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end







