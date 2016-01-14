//
//  EVFlightSearch.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVLocation.h"
#import "EVTravelers.h"
#import "EVFlightAttributes.h"

@protocol EVFlightSearchDelegate <EVSearchDelegate>

/***
 * handleFlightSearch - callback when Eva collects criteria to search for flights
 * @param isComplete - true if Eva considers the search flow "complete", ie. all the mandatory criteria have been requested by the user
 * @param origin - location of take-off
 * @param destination - location of landing
 * @param minDepartDateMin - range of dates the user wishes to depart on
 * @param departDateMax      if only a single date is entered the Max date will be equal to the Min date
 * @param returnDateMin - range of dates the user wishes to return - nill if one way flights
 * @param returnDateMax   if only a single date is entered the Max will be equal to the Min date
 * @param travelers - how many travelers, split into age categories
 * @param nonstop - True if the user requested nonstop, False if the user requested NOT nonstop, and null if the user did not mention this criteria
 * @param seatClass - array of seat classes (eg. economy, business, etc) requested by the user
 * @param airlines - array of airline codes requested by the user
 * @param redeye - True if the user requested Red Eye flight, False if the user requested NOT Red Eye flight, and null if the user did not mention this criteria
 * @param food - text describing food in flight as requested by the user, null if not mentioned
 * @param seatType - window/aisle seats, or null if not mentioned
 * @param sortBy - how should the results be sorted (eg. price, date, etc..), or null if not mentioned
 * @param sortOrder - ascending or descending or null if not mentioned
 */
- (EVCallbackResponse*)handleFlightSearch:(BOOL)isComplete
                                                   fromLocation:(EVLocation *)origin
                                                     toLocation:(EVLocation *) destination
                                                  minDepartDate:(NSDate *)departDateMin
                                                  maxDepartDate:(NSDate*) departDateMax
                                                  minReturnDate:(NSDate*)returnDateMin
                                                  maxReturnDate:(NSDate*)returnDateMax
                                                      travelers:(EVTravelers*)travelers
                                                        nonStop:(EVBool)nonstop
                                                    seatClasses:(NSArray*)seatClasses
                                                       airlines:(NSArray*)airlines
                                                         redEye:(EVBool)redeye
                                                       foodType:(EVFlightAttributesFoodType)food
                                                       seatType:(EVFlightAttributesSeatType)seatType
                                                         sortBy:(EVRequestAttributesSort)sortBy
                                                      sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end