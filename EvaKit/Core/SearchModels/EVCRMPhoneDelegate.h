//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMPhoneDelegate <EVSearchDelegate>

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


@end