//
//  EVFlightSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlightNavigateModel.h"
#import "EVFlightNavigateDelegate.h"

@interface EVFlightNavigateModel ()

@property (nonatomic, assign, readwrite) EVFlightPageType page;

@end

@implementation EVFlightNavigateModel

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVFlightPageType)page {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
    }
    return self;
}


+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVFlightPageType)page {
    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page] autorelease];
}


- (EVCallbackResponse*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVFlightNavigateDelegate)]) {
        return [(id<EVFlightNavigateDelegate>)delegate   navigateTo:(EVFlightPageType)self.page];
    }
    return [EVCallbackResponse responseWithNone];
}

- (void)dealloc {
    [super dealloc];
}

@end
