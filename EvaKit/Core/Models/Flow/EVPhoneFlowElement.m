//
//  EVStatementFlowElement.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVPhoneFlowElement.h"

@implementation EVPhoneFlowElement


+ (void)load {
    [self registerClass:self forElementType:EVFlowElementTypePhone];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        self.phoneNumber = [response objectForKey:@"Value"];
//        self.phoneType = [response objectForKey:@"PhoneType"];
    }
    return self;
}

@end
