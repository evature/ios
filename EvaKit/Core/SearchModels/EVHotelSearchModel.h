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
@property (nonatomic, assign, readonly) BOOL selfCatering;
@property (nonatomic, assign, readonly) BOOL bedAndBreakfast;
@property (nonatomic, assign, readonly) BOOL halfBoard;
@property (nonatomic, assign, readonly) BOOL fullBoard;
@property (nonatomic, assign, readonly) BOOL allInclusive;
@property (nonatomic, assign, readonly) BOOL drinksInclusive;

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

+ (instancetype)modelComplete:(BOOL)isComplete
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
