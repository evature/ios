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
    EVCRMPageTypeAppointments
};

typedef NS_ENUM(int16_t, EVCRMFilterType) {
    EVCRMFilterTypeNone = -1,
    EVCRMFilterTypeMyAccounts = 0,
    EVCRMFilterTypeTeamAccounts
};

typedef NS_ENUM(int16_t, EVCRMPhoneType) {
    EVCRMPhoneTypeOther = -1,
    EVCRMPhoneTypeMobile = 0,
    EVCRMPhoneTypeHome,
    EVCRMPhoneTypeLandLine,
    EVCRMPhoneTypeWork
};

@interface EVCRMAttributes : NSObject

@property (nonatomic, assign, readwrite) EVCRMPageType page;


- (instancetype)initWithResponse:(NSDictionary *)response;
+ (EVCRMPageType)stringToPageType:(NSString*)pageName;
+ (EVCRMPageType)fieldPathToPageType:(NSString*)fieldToPath;
+ (NSString*)pageTypeToString:(EVCRMPageType) page;
+ (NSString*)filterTypeToString:(EVCRMFilterType) filter;

@end
