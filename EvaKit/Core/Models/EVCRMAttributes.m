//
//  EVCruiseAttributes.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMAttributes.h"

@implementation EVCRMAttributes

static NSDictionary* pageKeys = nil;

+ (void)load {
    pageKeys = [@{@"Home": @(EVCRMPageTypeHome),
                  @"Feed": @(EVCRMPageTypeFeed),
                  @"Leads": @(EVCRMPageTypeLeads),
                  @"Opportunities": @(EVCRMPageTypeOpportunities),
                  @"SalesQuotes": @(EVCRMPageTypeSalesQuotes),
                  @"Accounts": @(EVCRMPageTypeAccounts),
                  @"Contacts": @(EVCRMPageTypeContacts),
                  @"Activities": @(EVCRMPageTypeActivities),
                  @"TodaysAppointments": @(EVCRMPageTypeTodaysAppointments),
                   } retain];

}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Navigate"]) {
            NSDictionary *navigateDict = [response objectForKey:@"Navigate"];
            if ([navigateDict objectForKey:@"Destination"] != nil) {
                NSNumber* val = [pageKeys objectForKey:[[[navigateDict objectForKey:@"Destination"]
                                                            stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                            stringByReplacingOccurrencesOfString:@"'" withString:@""]];
                if (val != nil) {
                    self.page = [val shortValue];
                } else {
                    self.page = EVCRMPageTypeOther;
                }
            } else {
                self.page = EVCRMPageTypeOther;
            }

            if ([navigateDict objectForKey:@"Team"] != nil) {
                if ([[navigateDict objectForKey:@"Team"] boolValue]) {
                    self.filter = EVCRMFilterTypeTeamAccounts;
                }
                else {
                    self.filter = EVCRMFilterTypeMyAccounts;
                }
            } else {
                self.filter = EVCRMFilterTypeMyAccounts;
            }
        }
        
    }
    return self;
}


@end
