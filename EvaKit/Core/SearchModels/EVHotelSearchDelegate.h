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

- (EVCallbackResponse*)handleHotelSearchWhichComplete:(BOOL)isComplete
                                             location:(EVLocation*)location
                                        arriveDateMin:(NSDate*)arriveDateMin
                                        arriveDateMax:(NSDate*)arriveDateMax
                                          durationMin:(NSInteger)durationMin
                                          durationMax:(NSInteger)durationMax
                                            travelers:(EVTravelers*)travelers
                                          hotelsChain:(NSArray*)chain
                                         selfCatering:(EVBool)selfCatering
                                      bedAndBreakfast:(EVBool)bedAndBreakfast
                                            halfBoard:(EVBool)halfBoard
                                            fullBoard:(EVBool)fullBoard
                                         allInclusive:(EVBool)allInclusive
                                      drinksInclusive:(EVBool)drinksInclusive
                                             minStars:(NSInteger)minStars
                                             maxStars:(NSInteger)maxStars
                                            amenities:(NSSet*)amenities
                                               sortBy:(EVRequestAttributesSort)sortBy
                                            sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end
