//
//  EVStatementFlowElement.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVPhoneFlowElement.h"
#import "EVLogger.h"
#import "EVCRMAttributes.h"

@implementation EVPhoneActionFlowElement

static NSDictionary* phoneTypes = nil;


+ (void)load {
    phoneTypes = [@{@"other": @(EVCRMPhoneTypeOther),
                            @"mobile": @(EVCRMPhoneTypeMobile),
                            @"home": @(EVCRMPhoneTypeHome),
                            @"landline": @(EVCRMPhoneTypeLandLine),
                            @"work": @(EVCRMPhoneTypeWork),
                            } retain];
    
    [self registerClass:self forElementType:EVFlowElementTypePhoneAction];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        NSString *url = [response objectForKey:@"URL"];
        NSArray *pathArray = [url componentsSeparatedByString:@"/"];
        if (![pathArray[0] isEqualToString:@"crm"]) {
            EV_LOG_ERROR(@"Expected path to start with CRM but was %@", url);
            return self;
        }
        
        NSString *action = [response objectForKey:@"Action"];
        if ([action isEqualToString:@"Open map"]) {
            self.action = EVPhoneActionFlowElementActionTypeOpenMap;
        }
        else if ([action isEqualToString:@"Call"]) {
            self.action = EVPhoneActionFlowElementActionTypeCall;
        }
        else {
            EV_LOG_ERROR(@"Unexpected phone-action action %@", action);
            self.action = EVPhoneActionFlowElementActionTypeOther;
        }
        
        // expecting one of:
        //         crm/contact/sub-page-id/phone-type
        //         crm/contact/sub-page-id
        //         crm/account/sub-page-id
        self.page = EVCRMPageTypeContacts;
        self.subPage = nil;
        NSUInteger count = [pathArray count];
        if (count > 2) {
            self.page = [EVCRMAttributes fieldPathToPageType:[pathArray objectAtIndex:1]];
        }
        if (count > 3) {
            self.subPage = [pathArray objectAtIndex:2];
        }
        if (count > 4) {
            self.phoneType = EVCRMPhoneTypeOther;
            if (self.action != EVPhoneActionFlowElementActionTypeCall) {
                EV_LOG_ERROR(@"Unexpected phone-action phone type %@ with action %@", [pathArray objectAtIndex:3], action);
            }
            NSNumber* val = [phoneTypes objectForKey:[[[[pathArray objectAtIndex:3] lowercaseString]
                                                          stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                         stringByReplacingOccurrencesOfString:@"'" withString:@""]];
            if (val != nil) {
                self.phoneType = [val shortValue];
            }
        }
    }
    return self;
}

@end
