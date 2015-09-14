//
//  EVHotelSearchModel.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVHotelSearchModel.h"

@interface EVHotelSearchModel ()

@property (nonatomic, strong, readwrite) EVLocation* location;

@property (nonatomic, strong, readwrite) NSDate* arriveDateMin;
@property (nonatomic, strong, readwrite) NSDate* arriveDateMax;
@property (nonatomic, assign, readwrite) NSInteger durationMin;
@property (nonatomic, assign, readwrite) NSInteger durationMax;
@property (nonatomic, strong, readwrite) EVTravelers* travelers;
@property (nonatomic, strong, readwrite) NSArray* chains;

// The hotel board:
@property (nonatomic, assign, readwrite) EVBool selfCatering;
@property (nonatomic, assign, readwrite) EVBool bedAndBreakfast;
@property (nonatomic, assign, readwrite) EVBool halfBoard;
@property (nonatomic, assign, readwrite) EVBool fullBoard;
@property (nonatomic, assign, readwrite) EVBool allInclusive;
@property (nonatomic, assign, readwrite) EVBool drinksInclusive;

// The quality of the hotel, measure in Stars
@property (nonatomic, assign, readwrite) NSInteger minStars;
@property (nonatomic, assign, readwrite) NSInteger maxStars;

@property (nonatomic, strong, readwrite) NSSet* amenities;

@property (nonatomic, assign, readwrite) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readwrite) EVRequestAttributesSortOrder sortOrder;

@end

@implementation EVHotelSearchModel

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
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.location = location;
        self.arriveDateMin = arriveDateMin;
        self.arriveDateMax = arriveDateMax;
        self.durationMin = durationMin;
        self.durationMax = durationMax;
        self.travelers = travelers;
        self.chains = chain;
        self.selfCatering = selfCatering;
        self.bedAndBreakfast = bedAndBreakfast;
        self.halfBoard = halfBoard;
        self.fullBoard = fullBoard;
        self.allInclusive = allInclusive;
        self.drinksInclusive = drinksInclusive;
        self.minStars = minStars;
        self.maxStars = maxStars;
        self.amenities = amenities;
        self.sortBy = sortBy;
        self.sortOrder = sortOrder;
    }
    return self;
}

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
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    return [[[self alloc] initWithComplete:isComplete location:location arriveDateMin:arriveDateMin arriveDateMax:arriveDateMax durationMin:durationMin durationMax:durationMax travelers:travelers hotelsChain:chain selfCatering:selfCatering bedAndBreakfast:bedAndBreakfast halfBoard:halfBoard fullBoard:fullBoard allInclusive:allInclusive drinksInclusive:drinksInclusive minStars:minStars maxStars:maxStars amenities:amenities sortBy:sortBy sortOrder:sortOrder] autorelease];
}

- (void)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVHotelSearchDelegate)]) {
        [(id<EVHotelSearchDelegate>)delegate handleHotelSearchWhichComplete:self.isComplete
                                                                   location:self.location
                                                              arriveDateMin:self.arriveDateMin
                                                              arriveDateMax:self.arriveDateMax
                                                                durationMin:self.durationMin
                                                                durationMax:self.durationMax
                                                                  travelers:self.travelers
                                                                hotelsChain:self.chains
                                                               selfCatering:self.selfCatering
                                                            bedAndBreakfast:self.bedAndBreakfast
                                                                  halfBoard:self.halfBoard
                                                                  fullBoard:self.fullBoard
                                                               allInclusive:self.allInclusive
                                                            drinksInclusive:self.drinksInclusive
                                                                   minStars:self.minStars
                                                                   maxStars:self.maxStars
                                                                  amenities:self.amenities
                                                                     sortBy:self.sortBy
                                                                  sortOrder:self.sortOrder];
    }
}

- (void)dealloc {
    self.location = nil;
    self.arriveDateMin = nil;
    self.arriveDateMax = nil;
    self.travelers = nil;
    self.chains = nil;
    self.amenities = nil;
    [super dealloc];
}

@end
