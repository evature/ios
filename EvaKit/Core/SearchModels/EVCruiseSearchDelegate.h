//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCruiseAttributes.h"
#import "EVLocation.h"

@protocol EVCruiseSearchDelegate <EVSearchDelegate>

- (void)handleCruiseSearchWhichComplete:(BOOL)isComplete
                                   from:(EVLocation*)from
                                     to:(EVLocation*)to
                               fromDate:(NSDate*)fromDate
                                 toDate:(NSDate*)toDate
                            minDuration:(NSInteger)minDuration
                            maxDuration:(NSInteger)maxDuration
                             attributes:(EVCruiseAttributes*)attributes
                                 sortBy:(EVRequestAttributesSort)sortBy
                              sortOrder:(EVRequestAttributesSortOrder)sortOrder;

@end