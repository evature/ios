//
//  EVCruiseAttributes.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(int16_t, EVCRMPageType) {
    EVCRMPageTypeOther = -1,
    EVCRMPageTypeHome = 0,
    EVCRMPageTypeFeed,
    EVCRMPageTypeLeads,
    EVCRMPageTypeOpportunities,
    EVCRMPageTypeSalesQuotes,
    EVCRMPageTypeAccounts,
    EVCRMPageTypeContacts,
    EVCRMPageTypeActivities,
    EVCRMPageTypeTodaysAppointments
};

typedef NS_ENUM(int16_t, EVCRMFilterType) {
    EVCRMFilterTypeMyAccounts = 0,
    EVCRMFilterTypeTeamAccounts
};


@interface EVCRMAttributes : NSObject

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, assign, readwrite) EVCRMFilterType filter;


- (instancetype)initWithResponse:(NSDictionary *)response;
+ (EVCRMPageType)stringToPageType:(NSString*)pageName;
+ (EVCRMPageType)fieldPathToPageType:(NSString*)fieldTopPath;

@end
