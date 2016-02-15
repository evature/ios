//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCreateFlowElement.h"

@implementation EVCreateFlowElement
static NSDictionary* itemTypes = nil;


+ (void)load {
    itemTypes = [@{@"Unknown": @(EVCreateFlowElementItemTypeUnknown),
                   @"Appointment": @(EVCreateFlowElementItemTypeAppointment)
                } retain];

    [self registerClass:self forElementType:EVFlowElementTypeCreate];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        self.details = [response objectForKey:@"Details"];
        NSNumber* val = [itemTypes objectForKey:[response objectForKey:@"ItemType"]];
        if (val != nil) {
            self.itemType = [val shortValue];
        } else {
            self.itemType = EVCreateFlowElementItemTypeUnknown;
        }
    }
    return self;
}

@end
