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
    pageKeys = [@{@"home": @(EVCRMPageTypeHome),
                  @"feed": @(EVCRMPageTypeFeed),
                  @"leads": @(EVCRMPageTypeLeads),
                  @"opportunities": @(EVCRMPageTypeOpportunities),
                  @"salesquotes": @(EVCRMPageTypeSalesQuotes),
                  @"accounts": @(EVCRMPageTypeAccounts),
                  @"contacts": @(EVCRMPageTypeContacts),
                  @"activities": @(EVCRMPageTypeActivities),
                  @"todaysappointments": @(EVCRMPageTypeTodaysAppointments),
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
        NSNumber* val = [pageKeys objectForKey:[[[pageName lowercaseString]
                                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                 stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        if (val != nil) {
            return [val shortValue];
        }
    }
    return EVCRMPageTypeOther;
}

+ (EVCRMPageType)fieldPathToPageType:(NSString*)fieldToPath {
    if (fieldToPath) {
        NSNumber* val = [fieldPageKeys objectForKey:[[[fieldToPath lowercaseString]
                                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        if (val != nil) {
            return [val shortValue];
        }
    }
    return EVCRMPageTypeOther;
}

+ (NSString*)pageTypeToString:(EVCRMPageType) page {
    switch (page) {
        case EVCRMPageTypeHome: return @"Home";
        case EVCRMPageTypeFeed: return @"Feed";
        case EVCRMPageTypeLeads: return @"Leads";
        case EVCRMPageTypeOpportunities: return @"Opportunities";
        case EVCRMPageTypeSalesQuotes: return @"SalesQuotes";
        case EVCRMPageTypeAccounts: return @"Accounts";
        case EVCRMPageTypeContacts: return @"Contacts";
        case EVCRMPageTypeActivities: return @"Activities";
        case EVCRMPageTypeTodaysAppointments: return @"TodaysAppointments";
        default: return @"Other";
    }
}

+ (NSString*)filterTypeToString:(EVCRMFilterType) filter {
    switch(filter) {
        case EVCRMFilterTypeMyAccounts: return @"My";
        case EVCRMFilterTypeNone: return @"None";
        case EVCRMFilterTypeTeamAccounts: return @"Team";
        default: return @"Other";
    }
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
