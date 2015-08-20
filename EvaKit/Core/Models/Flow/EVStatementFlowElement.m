//
//  EVStatementFlowElement.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVStatementFlowElement.h"

@implementation EVStatementFlowElement

static NSDictionary* statementTypeKeys = nil;

+ (void)load {
    statementTypeKeys = [@{@"Other": @(EVStatementFlowElementTypeOther),
                           @"Understanding": @(EVStatementFlowElementTypeUnderstanding),
                           @"Chat": @(EVStatementFlowElementTypeChat),
                           @"Unsupported": @(EVStatementFlowElementTypeUnsupported),
                           @"Unknown Expression": @(EVStatementFlowElementTypeUnknownExpression)
                           } retain];
    [self registerClass:self forElementType:EVFlowElementTypeStatement];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        if ([response objectForKey:@"StatementType"] != nil) {
            NSNumber* val = [statementTypeKeys objectForKey:[response objectForKey:@"StatementType"]];
            if (val != nil) {
                self.statementType = [val shortValue];
            } else {
                self.statementType = EVStatementFlowElementTypeOther;
            }
        } else {
            self.statementType = EVStatementFlowElementTypeOther;
        }
    }
    return self;
}

@end
