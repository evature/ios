//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMDataDelegate <EVSearchDelegate>

@optional

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


//  setField
//  --------
//
//  If the user says "Set the probability to seventy percent"
//  Then -
//  This delegate will be activated with:
//    fieldPath = @"probability"
//         page = EVCRMPageTypeOpportunities
//        objId = UUID of the object, or nil
//        value = @{ @"type" : EVValueTypeNumber,  @"value" : [NSNumber numberWithFloat:0.7f] }
- (EVCallbackResult*)setField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId toValue:(NSDictionary*)value;


// create methods:
// ---------------


// createMeeting
//  paticipants are array of NSDictionary containing
- (EVCallbackResult*)createMeetingOnDate:(NSDate*)date withDuration:(NSNumber*)hours withSubject:(NSString*)subject withParticipants:(NSArray*)participants;


@end