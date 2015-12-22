//
//  EVSearchDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/18/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContextBase.h"
#import "EVCallbackResponse.h"

@class EVResponse;

// This is simple parent protocol for all search delegates. Use more concrete delegates rather than this
@protocol EVSearchDelegate <NSObject>
@optional

#pragma mark === Getters
- (EVSearchContextType)searchContext;

- (EVStyledString*)helloMessage;

#pragma mark === Callbacks

// eg. "What is my departure time?"
- (EVCallbackResponse*)departureTime;

// eg. "What is my arrival time?"
- (EVCallbackResponse*)arrivalTime;

// eg. "What is the boarding time?"
- (EVCallbackResponse*)boardingTime;

// eg. "What is my gate number?"
- (EVCallbackResponse*)gate;

// eg. "Show me my boarding pass"
- (EVCallbackResponse*)boardingPass;

// eg. "Show me my trip info"
- (EVCallbackResponse*)itinerary;

#pragma mark === Raw response
- (void)evSearchGotResponse:(EVResponse*)response;
- (void)evSearchGotAnError:(NSError*)error;

@end