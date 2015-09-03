//
//  EVFlightSearchModel.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlightSearchModel.h"

@interface EVFlightSearchModel ()

@property (nonatomic, strong, readwrite) EVLocation* origin;
@property (nonatomic, strong, readwrite) EVLocation* destination;
@property (nonatomic, assign, readwrite) EVRequestAttributesSort sortBy;

@property (nonatomic, strong, readwrite) NSDate* departDateMin;
@property (nonatomic, strong, readwrite) NSDate* departDateMax;
@property (nonatomic, strong, readwrite) NSDate* returnDateMin;
@property (nonatomic, strong, readwrite) NSDate* returnDateMax;
@property (nonatomic, strong, readwrite) EVTravelers* travelers;

@property (nonatomic, assign, readwrite) EVBool nonstop; // A Non stop flight - Boolean attribute; null= not specified, false = explicitly request NOT nonstop, true = explicitly requested nonstop flight
@property (nonatomic, assign, readwrite) EVBool redeye; // A Red eye flight - Boolean attribute; null= not specified, false = explicitly request NOT red eye, true = explicitly requested red eye flight
@property (nonatomic, assign, readwrite) EVBool oneWay;
@property (nonatomic, strong, readwrite) NSArray* airlines;
@property (nonatomic, assign, readwrite) EVFlightAttributesFoodType food;
@property (nonatomic, assign, readwrite) EVFlightAttributesSeatType seatType;
@property (nonatomic, strong, readwrite) NSArray* seatClasses;
@property (nonatomic, assign, readwrite) EVRequestAttributesSortOrder sortOrder;

@end

@implementation EVFlightSearchModel

- (instancetype)initWithComplete:(BOOL)isComplete
                          origin:(EVLocation*)origin
                     destination:(EVLocation*)destination
                   departDateMin:(NSDate*)departDateMin
                   departDateMax:(NSDate*)departDateMax
                   returnDateMin:(NSDate*)returnDateMin
                   returnDateMax:(NSDate*)returnDateMax
                       travelers:(EVTravelers*)travelers
                         nonstop:(EVBool)nonstop
                          redeye:(EVBool)redeye
                          oneWay:(EVBool)oneWay
                        airlines:(NSArray*)airlines
                            food:(EVFlightAttributesFoodType)food
                        seatType:(EVFlightAttributesSeatType)seatType
                     seatClasses:(NSArray*)seatClasses
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.origin = origin;
        self.destination = destination;
        self.departDateMin = departDateMin;
        self.departDateMax = departDateMax;
        self.returnDateMin = returnDateMin;
        self.returnDateMax = returnDateMax;
        self.travelers = travelers;
        self.nonstop = nonstop;
        self.redeye = redeye;
        self.oneWay = oneWay;
        self.airlines = airlines;
        self.food = food;
        self.seatType = seatType;
        self.seatClasses = seatClasses;
        self.sortBy = sortBy;
        self.sortOrder = sortOrder;
    }
    return self;
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       origin:(EVLocation*)origin
                  destination:(EVLocation*)destination
                departDateMin:(NSDate*)departDateMin
                departDateMax:(NSDate*)departDateMax
                returnDateMin:(NSDate*)returnDateMin
                returnDateMax:(NSDate*)returnDateMax
                    travelers:(EVTravelers*)travelers
                      nonstop:(EVBool)nonstop
                       redeye:(EVBool)redeye
                       oneWay:(EVBool)oneWay
                     airlines:(NSArray*)airlines
                         food:(EVFlightAttributesFoodType)food
                     seatType:(EVFlightAttributesSeatType)seatType
                  seatClasses:(NSArray*)seatClasses
                       sortBy:(EVRequestAttributesSort)sortBy
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    return [[[self alloc] initWithComplete:isComplete origin:origin destination:destination departDateMin:departDateMin departDateMax:departDateMax returnDateMin:returnDateMin returnDateMax:returnDateMax travelers:travelers nonstop:nonstop redeye:redeye oneWay:oneWay airlines:airlines food:food seatType:seatType seatClasses:seatClasses sortBy:sortBy sortOrder:sortOrder] autorelease];
}

- (void)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVFlightSearchDelegate)]) {
        if (self.oneWay) {
            [(id<EVFlightSearchDelegate>)delegate handleOneWayFlightSearchWhichComplete:self.isComplete
                                                                           fromLocation:self.origin
                                                                             toLocation:self.destination
                                                                          minDepartDate:self.departDateMin
                                                                          maxDepartDate:self.departDateMax
                                                                              travelers:self.travelers
                                                                                nonStop:self.nonstop
                                                                            seatClasses:self.seatClasses
                                                                               airlines:self.airlines
                                                                                 redEye:self.redeye
                                                                               foodType:self.food
                                                                               seatType:self.seatType
                                                                                 sortBy:self.sortBy
                                                                              sortOrder:self.sortOrder];
        } else {
            [(id<EVFlightSearchDelegate>)delegate handleRoundTripFlightSearchWhichComplete:self.isComplete
                                                                           fromLocation:self.origin
                                                                             toLocation:self.destination
                                                                          minDepartDate:self.departDateMin
                                                                          maxDepartDate:self.departDateMax
                                                                             minReturnDate:self.returnDateMin
                                                                             maxReturnDate:self.returnDateMax
                                                                              travelers:self.travelers
                                                                                nonStop:self.nonstop
                                                                            seatClasses:self.seatClasses
                                                                               airlines:self.airlines
                                                                                 redEye:self.redeye
                                                                               foodType:self.food
                                                                               seatType:self.seatType
                                                                                 sortBy:self.sortBy
                                                                              sortOrder:self.sortOrder];
        }
    }
}

@end
