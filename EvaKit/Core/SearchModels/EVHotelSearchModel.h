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

@property (nonatomic, strong, readonly) EVHotelAttributes *attributes;

@property (nonatomic, assign, readonly) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readonly) EVRequestAttributesSortOrder sortOrder;

- (instancetype)initWithComplete:(BOOL)isComplete
                        location:(EVLocation*)location
                   arriveDateMin:(NSDate*)arriveDateMin
                   arriveDateMax:(NSDate*)arriveDateMax
                     durationMin:(NSInteger)durationMin
                     durationMax:(NSInteger)durationMax
                       travelers:(EVTravelers*)travelers
                      attributes:(EVHotelAttributes*)attributes
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder;

+ (instancetype)modelComplete:(BOOL)isComplete
                     location:(EVLocation*)location
                arriveDateMin:(NSDate*)arriveDateMin
                arriveDateMax:(NSDate*)arriveDateMax
                  durationMin:(NSInteger)durationMin
                  durationMax:(NSInteger)durationMax
                    travelers:(EVTravelers*)travelers
                   attributes:(EVHotelAttributes*)attributes
                       sortBy:(EVRequestAttributesSort)sortBy
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end
