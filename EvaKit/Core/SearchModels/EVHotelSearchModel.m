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

@property (nonatomic, strong, readwrite) EVHotelAttributes *attributes;

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
                      attributes:(EVHotelAttributes*)attributes
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
        self.attributes = attributes;
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
                   attributes:(EVHotelAttributes*)attributes
                       sortBy:(EVRequestAttributesSort)sortBy
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    return [[[self alloc] initWithComplete:isComplete location:location arriveDateMin:arriveDateMin arriveDateMax:arriveDateMax durationMin:durationMin durationMax:durationMax travelers:travelers attributes:attributes sortBy:sortBy sortOrder:sortOrder] autorelease];
}

- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    
    NSDate *checkoutDate = nil;
    if (self.durationMin > 0 && self.arriveDateMin != nil) {
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:self.durationMin];
        checkoutDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.arriveDateMin options:0];
    }
    
    
    if ([delegate conformsToProtocol:@protocol(EVHotelSearchDelegate)]) {
        return [(id<EVHotelSearchDelegate>)delegate handleHotelSearchWhichComplete:self.isComplete
                                                                   location:self.location
                                                              arriveDateMin:self.arriveDateMin
                                                              arriveDateMax:self.arriveDateMax
                                                                durationMin:self.durationMin
                                                                durationMax:self.durationMax
                                                               checkoutDate:checkoutDate
                                                                  travelers:self.travelers
                                                                 attributes:self.attributes                                                                     sortBy:self.sortBy
                                                                  sortOrder:self.sortOrder];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.location = nil;
    self.arriveDateMin = nil;
    self.arriveDateMax = nil;
    self.travelers = nil;
    self.attributes = nil;
    [super dealloc];
}

@end
