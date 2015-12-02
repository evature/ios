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
//      objType = EVCRMPageTypeOpportunities
//        objId = 0
//        value = @{ @"type" : EVValueTypeFloat,  @"value" : [NSNumber numberWithFloat:0.7f] }
- (void) setField:(NSString*)fieldPath forObject:(EVCRMPageType)objType withId:(int)objId toValue:(NSDictionary*)value;


@end