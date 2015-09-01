//
//  EVCruiseSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCruiseSearchDelegate.h"
#import "EVCruiseAttributes.h"

@interface EVCruiseSearchModel : EVSearchModel

@property (nonatomic, strong, readonly) EVLocation* from;
@property (nonatomic, strong, readonly) EVLocation* to;
@property (nonatomic, strong, readonly) NSDate* fromDate;
@property (nonatomic, strong, readonly) NSDate* toDate;
@property (nonatomic, assign, readonly) NSInteger durationMin;
@property (nonatomic, assign, readonly) NSInteger durationMax;
@property (nonatomic, strong, readonly) EVCruiseAttributes* attributes;
@property (nonatomic, assign, readonly) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readonly) EVRequestAttributesSortOrder sortOrder;

- (instancetype)initWithComplete:(BOOL)isComplete
                    fromLocation:(EVLocation*)from
                      toLocation:(EVLocation*)to
                        fromDate:(NSDate*)fromDate
                          toDate:(NSDate*)toDate
                     durationMin:(NSInteger)durationMin
                     durationMax:(NSInteger)durationMax
                cruiseAttributes:(EVCruiseAttributes*)attributes
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder;

+ (instancetype)modelComplete:(BOOL)isComplete
                 fromLocation:(EVLocation*)from
                   toLocation:(EVLocation*)to
                     fromDate:(NSDate*)fromDate
                       toDate:(NSDate*)toDate
                  durationMin:(NSInteger)durationMin
                  durationMax:(NSInteger)durationMax
             cruiseAttributes:(EVCruiseAttributes*)attributes
                       sortBy:(EVRequestAttributesSort)sortBy
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end
