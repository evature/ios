//
//  EVCruiseAttributes.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMAttributes.h"

@implementation EVCRMAttributes

static NSDictionary* pageKeys = nil;
static NSDictionary* fieldPageKeys = nil;

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
    fieldPageKeys = [@{@"lead": @(EVCRMPageTypeLeads),
                       @"opportunity": @(EVCRMPageTypeOpportunities),
                       @"salesquote": @(EVCRMPageTypeSalesQuotes),
                       @"account": @(EVCRMPageTypeAccounts),
                       @"contact": @(EVCRMPageTypeContacts),
                       @"activity": @(EVCRMPageTypeActivities)
                       } retain];
}

+ (EVCRMPageType)stringToPageType:(NSString*)pageName {
    if (pageName) {
        NSNumber* val = [pageKeys objectForKey:[[pageName
                                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                 stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        if (val != nil) {
            return [val shortValue];
        }
    }
    return EVCRMPageTypeOther;
}

+ (EVCRMPageType)fieldPathToPageType:(NSString*)fieldTopPath {
    if (fieldTopPath) {
        NSNumber* val = [fieldPageKeys objectForKey:[[fieldTopPath
                                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        if (val != nil) {
            return [val shortValue];
        }
    }
    return EVCRMPageTypeOther;
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Navigate"]) {
            NSDictionary *navigateDict = [response objectForKey:@"Navigate"];
            self.page = [EVCRMAttributes stringToPageType: [navigateDict objectForKey:@"Destination"]];

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
