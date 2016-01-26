//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVFlightAttributes.h"

@protocol EVFlightNavigateDelegate <EVSearchDelegate>

- (EVCallbackResult*)navigateTo:(EVFlightPageType)page;

@optional
#pragma mark === Callbacks

// eg. "What is my departure time?"
- (EVCallbackResult*)departureTime;

// eg. "What is my arrival time?"
- (EVCallbackResult*)arrivalTime;

// eg. "What is the boarding time?"
- (EVCallbackResult*)boardingTime;

// eg. "What is my gate number?"
- (EVCallbackResult*)gate;

// eg. "Show me my boarding pass"
- (EVCallbackResult*)boardingPass;

// eg. "Show me my trip info"
- (EVCallbackResult*)itinerary;

@end