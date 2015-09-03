//
//  EVHotelSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVHotelSearchDelegate.h"

@interface EVHotelSearchModel : EVSearchModel

@property (nonatomic, strong, readonly) EVLocation* location;

@property (nonatomic, strong, readonly) NSDate* arriveDateMin;
@property (nonatomic, strong, readonly) NSDate* arriveDateMax;
@property (nonatomic, assign, readonly) NSInteger durationMin;
@property (nonatomic, assign, readonly) NSInteger durationMax;
@property (nonatomic, strong, readonly) EVTravelers* travelers;
@property (nonatomic, strong, readonly) NSArray* chains;

// The hotel board:
@property (nonatomic, assign, readonly) EVBool selfCatering;
@property (nonatomic, assign, readonly) EVBool bedAndBreakfast;
@property (nonatomic, assign, readonly) EVBool halfBoard;
@property (nonatomic, assign, readonly) EVBool fullBoard;
@property (nonatomic, assign, readonly) EVBool allInclusive;
@property (nonatomic, assign, readonly) EVBool drinksInclusive;

// The quality of the hotel, measure in Stars
@property (nonatomic, assign, readonly) NSInteger minStars;
@property (nonatomic, assign, readonly) NSInteger maxStars;

@property (nonatomic, strong, readonly) NSSet* amenities;

@property (nonatomic, assign, readonly) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readonly) EVRequestAttributesSortOrder sortOrder;

- (instancetype)initWithComplete:(BOOL)isComplete
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

+ (instancetype)modelComplete:(BOOL)isComplete
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
