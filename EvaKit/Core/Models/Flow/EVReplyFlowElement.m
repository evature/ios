//
//  EVReplyFlowElement.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVReplyFlowElement.h"

@implementation EVReplyFlowElement

+ (void)load {
    [self registerClass:self forElementType:EVFlowElementTypeReply];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        self.attributeKey = [response objectForKey:@"AttributeKey"];
        self.attributeType = [response objectForKey:@"AttributeType"];
    }
    return self;
}

@end
