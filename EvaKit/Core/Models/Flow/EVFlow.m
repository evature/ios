//
//  EVFlow.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlow.h"
#import "EVFlightFlowElement.h"

@implementation EVFlow

- (instancetype)initWithResponse:(NSArray*)response andLocations:(NSArray*)locations {
    self = [super init];
    if (self != nil) {
        NSMutableIndexSet* skipIndexSet = [NSMutableIndexSet indexSet];
        NSMutableArray* elements = [NSMutableArray array];
        for (int index = 0; index < [response count]; index++) {
            if ([skipIndexSet containsIndex:index]) {
                continue;
            }
            EVFlowElement* element = [EVFlowElement elementWithResponse:[response objectAtIndex:index] andLocations:locations];
            if (element != nil) {
                if (element.type == EVFlowElementTypeFlight) {
                    [skipIndexSet addIndex:((EVFlightFlowElement*)element).actionIndex];
                }
                [elements addObject:element];
            }
        }
        self.flowElements = [NSArray arrayWithArray:elements];
    }
    return self;
}

- (void)dealloc {
    self.flowElements = nil;
    [super dealloc];
}

@end
