//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCruiseSearchModel.h"

@interface EVCruiseSearchModel ()

@property (nonatomic, strong, readwrite) EVLocation* from;
@property (nonatomic, strong, readwrite) EVLocation* to;
@property (nonatomic, strong, readwrite) NSDate* fromDate;
@property (nonatomic, strong, readwrite) NSDate* toDate;
@property (nonatomic, assign, readwrite) NSInteger durationMin;
@property (nonatomic, assign, readwrite) NSInteger durationMax;
@property (nonatomic, strong, readwrite) EVCruiseAttributes* attributes;
@property (nonatomic, assign, readwrite) EVRequestAttributesSort sortBy;
@property (nonatomic, assign, readwrite) EVRequestAttributesSortOrder sortOrder;

@end

@implementation EVCruiseSearchModel

- (instancetype)initWithComplete:(BOOL)isComplete
                    fromLocation:(EVLocation*)from
                      toLocation:(EVLocation*)to
                        fromDate:(NSDate*)fromDate
                          toDate:(NSDate*)toDate
                     durationMin:(NSInteger)durationMin
                     durationMax:(NSInteger)durationMax
                cruiseAttributes:(EVCruiseAttributes*)attributes
                          sortBy:(EVRequestAttributesSort)sortBy
                       sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.from = from;
        self.to = to;
        self.fromDate = fromDate;
        self.toDate = toDate;
        self.durationMin = durationMin;
        self.durationMax = durationMax;
        self.attributes = attributes;
        self.sortBy = sortBy;
        self.sortOrder = sortOrder;
    }
    return self;
}

+ (instancetype)modelComplete:(BOOL)isComplete
                 fromLocation:(EVLocation*)from
                   toLocation:(EVLocation*)to
                     fromDate:(NSDate*)fromDate
                       toDate:(NSDate*)toDate
                  durationMin:(NSInteger)durationMin
                  durationMax:(NSInteger)durationMax
             cruiseAttributes:(EVCruiseAttributes*)attributes
                       sortBy:(EVRequestAttributesSort)sortBy
                    sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    return [[[self alloc] initWithComplete:isComplete
                             fromLocation:from
                               toLocation:to
                                 fromDate:fromDate
                                   toDate:toDate
                              durationMin:durationMin
                              durationMax:durationMax
                         cruiseAttributes:attributes
                                   sortBy:sortBy
                                 sortOrder:sortOrder] autorelease];
}

- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCruiseSearchDelegate)]) {
        return [(id<EVCruiseSearchDelegate>)delegate handleCruiseSearchWhichComplete:self.isComplete
                                                                         from:self.from
                                                                           to:self.to
                                                                     fromDate:self.fromDate
                                                                       toDate:self.toDate
                                                                  minDuration:self.durationMin
                                                                  maxDuration:self.durationMax
                                                                   attributes:self.attributes
                                                                       sortBy:self.sortBy
                                                                    sortOrder:self.sortOrder];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.from = nil;
    self.to = nil;
    self.fromDate = nil;
    self.toDate = nil;
    
    self.attributes = nil;
    [super dealloc];
}

@end
