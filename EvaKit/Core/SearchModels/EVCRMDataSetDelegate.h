//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMDataSetDelegate <EVSearchDelegate>

//  setField
//  --------
//
//  If the user says "Set the probability to seventy percent"
//  Then -
//  This delegate will be activated with:
//    fieldPath = @"probability"
//         page = EVCRMPageTypeOpportunities
//        objId = 0
//        value = @{ @"type" : EVValueTypeNumber,  @"value" : [NSNumber numberWithFloat:0.7f] }
- (EVCallbackResponse*)setField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(int)objId toValue:(NSDictionary*)value;


@end