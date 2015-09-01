//
//  EVFlightSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVFlightSearchDelegate.h"

@interface EVFlightSearchModel : EVSearchModel

@property (nonatomic, strong, readonly) EVLocation* origin;
@property (nonatomic, strong, readonly) EVLocation* destination;
@property (nonatomic, assign, readonly) EVRequestAttributesSort sortBy;

@property (nonatomic, strong, readonly) NSDate* departDateMin;
@property (nonatomic, strong, readonly) NSDate* departDateMax;
@property (nonatomic, strong, readonly) NSDate* returnDateMin;
@property (nonatomic, strong, readonly) NSDate* returnDateMax;
@property (nonatomic, strong, readonly) EVTravelers* travelers;

@property (nonatomic, assign, readonly) BOOL nonstop; // A Non stop flight - Boolean attribute; null= not specified, false = explicitly request NOT nonstop, true = explicitly requested nonstop flight
@property (nonatomic, assign, readonly) BOOL redeye; // A Red eye flight - Boolean attribute; null= not specified, false = explicitly request NOT red eye, true = explicitly requested red eye flight
@property (nonatomic, assign, readonly) BOOL oneWay;
@property (nonatomic, strong, readonly) NSArray* airlines;
@property (nonatomic, assign, readonly) EVFlightAttributesFoodType food;
@property (nonatomic, assign, readonly) EVFlightAttributesSeatType seatType;
@property (nonatomic, strong, readonly) NSArray* seatClasses;
@property (nonatomic, assign, readonly) EVRequestAttributesSortOrder sortOrder;

- (instancetype)initWithComplete:(BOOL)isComplete
                          origin:(EVLocation*)origin
                     destination:(EVLocation*)destination
                   departDateMin:(NSDate*)departDateMin
                   departDateMax:(NSDate*)departDateMax
                   returnDateMin:(NSDate*)returnDateMin
                   returnDateMax:(NSDate*)returnDateMax
                       travelers:(EVTravelers*)travelers
                         nonstop:(BOOL)nonstop
                          redeye:(BOOL)redeye
                          oneWay:(BOOL)oneWay
                        airlines:(NSArray*)airlines
                            food:(EVFlightAttributesFoodType)food
                        seatType:(EVFlightAttributesSeatType)seatType
                     seatClasses:(NSArray*)seatClasses
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder;

+ (instancetype)modelComplete:(BOOL)isComplete
                          origin:(EVLocation*)origin
                     destination:(EVLocation*)destination
                   departDateMin:(NSDate*)departDateMin
                   departDateMax:(NSDate*)departDateMax
                   returnDateMin:(NSDate*)returnDateMin
                   returnDateMax:(NSDate*)returnDateMax
                       travelers:(EVTravelers*)travelers
                         nonstop:(BOOL)nonstop
                          redeye:(BOOL)redeye
                          oneWay:(BOOL)oneWay
                        airlines:(NSArray*)airlines
                            food:(EVFlightAttributesFoodType)food
                        seatType:(EVFlightAttributesSeatType)seatType
                     seatClasses:(NSArray*)seatClasses
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end
