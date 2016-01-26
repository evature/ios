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
@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;

@end

@implementation EVCRMNavigateModel

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                        subPage:(NSString*)subPage
                   crmAttributes:(EVCRMAttributes *)attributes {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.attributes = attributes;
        self.page = page;
        self.subPage = subPage;
    }
    return self;
}


+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                crmAttributes:(EVCRMAttributes *)attributes {
    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                  subPage:subPage
                             crmAttributes:attributes] autorelease];
}


- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMNavigateDelegate)]) {
        return [(id<EVCRMNavigateDelegate>)delegate   navigateTo:(EVCRMPageType)self.page
                                               withSubPage:self.subPage
                                               ofTeam:(EVCRMFilterType)self.attributes.filter];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.attributes = nil;
    [super dealloc];
}

@end
