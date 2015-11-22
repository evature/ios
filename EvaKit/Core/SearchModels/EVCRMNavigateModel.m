//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMNavigateModel.h"
#import "EVCRMNavigateDelegate.h"

@interface EVCRMNavigateModel ()

@property (nonatomic, strong, readwrite) EVCRMAttributes* attributes;

@end

@implementation EVCRMNavigateModel

- (instancetype)initWithComplete:(BOOL)isComplete
                crmAttributes:(EVCRMAttributes *)attributes {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.attributes = attributes;
    }
    return self;
}


+ (instancetype)modelComplete:(BOOL)isComplete
                 crmAttributes:(EVCRMAttributes *)attributes {
    return [[[self alloc] initWithComplete:isComplete
                             crmAttributes:attributes] autorelease];
}


- (void)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMNavigateDelegate)]) {
        [(id<EVCRMNavigateDelegate>)delegate   navigateTo:(EVCRMPageType)self.attributes.page
                                               withSubPage:0
                                               ofTeam:(EVCRMFilterType)self.attributes.filter];
    }
}

- (void)dealloc {
    self.attributes = nil;
    [super dealloc];
}

@end
