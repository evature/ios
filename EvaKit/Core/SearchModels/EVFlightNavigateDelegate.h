//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVFlightAttributes.h"

@protocol EVFlightNavigateDelegate <EVSearchDelegate>

- (EVCallbackResponse*)navigateTo:(EVFlightPageType)page;

@end