//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMNavigateModel.h"
#import "EVCRMNavigateDelegate.h"

@interface EVCRMNavigateModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;
@property (nonatomic, strong, readwrite) NSDictionary* filter;

@end

@implementation EVCRMNavigateModel

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                          filter:(NSDictionary*)filter {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.subPage = subPage;
        self.filter = filter;
    }
    return self;
}


+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                       filter:(NSDictionary*)filter {
    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                   subPage:subPage
                                    filter:filter] autorelease];
}


- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMNavigateDelegate)]) {
        return [(id<EVCRMNavigateDelegate>)delegate   navigateTo:(EVCRMPageType)self.page
                                                     withSubPage:self.subPage
                                                      withFilter:self.filter];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.filter = nil;
    self.subPage = nil;
    [super dealloc];
}

@end
