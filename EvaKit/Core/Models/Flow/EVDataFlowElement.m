//
//  EVStatementFlowElement.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVDataFlowElement.h"

@implementation EVDataFlowElement

static NSDictionary* verbTypeKeys = nil;

+ (void)load {
    verbTypeKeys = [@{@"Other": @(EVDataFlowElementVerbTypeOther),
                           @"Set": @(EVDataFlowElementVerbTypeSet),
                           @"Get": @(EVDataFlowElementVerbTypeGet),
                           } retain];
    [self registerClass:self forElementType:EVFlowElementTypeData];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        if ([response objectForKey:@"Verb"] != nil) {
            NSNumber* val = [verbTypeKeys objectForKey:[response objectForKey:@"Verb"]];
            if (val != nil) {
                self.verb = [val shortValue];
            } else {
                self.verb = EVDataFlowElementVerbTypeOther;
            }
        } else {
            self.verb = EVDataFlowElementVerbTypeOther;
        }
        
        self.fieldPath = [response objectForKey:@"URL"];
        
        self.value = [response objectForKey:@"Value"];
        if ([self.value isKindOfClass:[NSDate class]]) {
            self.valueType = @(EVDataFlowElementValueTypeDate);
        }
        else if ([self.value isKindOfClass:[NSNumber class]]) {
            self.valueType = @(EVDataFlowElementValueTypeNumber);
        }
        else {
            self.valueType = @(EVDataFlowElementValueTypeString);
        }
    }
    return self;
}

@end
