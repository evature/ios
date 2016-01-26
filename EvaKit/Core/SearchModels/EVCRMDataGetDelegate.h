//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMDataGetDelegate <EVSearchDelegate>

//  getField
//  --------
//
//  If the user says "Get the probability of coca cola opportunity"
//  Then -
//  This delegate will be activated with:
//    fieldPath = @"probability"
//         page = EVCRMPageTypeOpportunities
//        objId = UUID of the object, or nil
- (EVCallbackResult*)getField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId;


@end