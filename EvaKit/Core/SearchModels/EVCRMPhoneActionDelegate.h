//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"


// Actions that are activated outside of the App, eg. make a phone call, navigate a car, etc...
@protocol EVCRMPhoneActionDelegate <EVSearchDelegate>

//  phoneCall
//  --------
//
//  If the user says "Call Bill Gates on mobile"
//  Then -
//  This delegate will be activated with:
//         page = EVCRMPageTypeContact
//        objId = UUID of the contact, or nil
//        phoneType = EVPhoneTypeMobile
- (EVCallbackResult*)phoneCall:(EVCRMPageType)page withId:(NSString*)objId withPhoneType:(EVCRMPhoneType)phoneType;


//  open map
//  --------
//
//  If the user says "navigate to the office of Coca Cola"
//  Then -
//  This delegate will be activated with:
//         page = EVCRMPageTypeAccount
//        objId = UUID of the account, or nil
- (EVCallbackResult*)openMap:(EVCRMPageType)page withId:(NSString*)objId;



@end