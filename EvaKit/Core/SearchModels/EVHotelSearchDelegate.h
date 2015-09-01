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

- (void)handleHotelSearchWhichComplete:(BOOL)isComplete
                              location:(EVLocation*)location
                         arriveDateMin:(NSDate*)arriveDateMin
                         arriveDateMax:(NSDate*)arriveDateMax
                           durationMin:(NSInteger)durationMin
                           durationMax:(NSInteger)durationMax
                             travelers:(EVTravelers*)travelers
                           hotelsChain:(NSArray*)chain
                          selfCatering:(BOOL)selfCatering
                       bedAndBreakfast:(BOOL)bedAndBreakfast
                             halfBoard:(BOOL)halfBoard
                             fullBoard:(BOOL)fullBoard
                          allInclusive:(BOOL)allInclusive
                       drinksInclusive:(BOOL)drinksInclusive
                              minStars:(NSInteger)minStars
                              maxStars:(NSInteger)maxStars
                             amenities:(NSSet*)amenities
                                sortBy:(EVRequestAttributesSort)sortBy
                             sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end
