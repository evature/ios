//
//  EVResponse.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVChat.h"
#import "EVDialog.h"
#import "EVLocation.h"
#import "EVSabre.h"
#import "EVServiceAttributes.h"
#import "EVCruiseAttributes.h"
#import "EVCRMAttributes.h"
#import "EVTravelers.h"
#import "EVMoney.h"
#import "EVPNRAttributes.h"
#import "EVWarning.h"
#import "EVParsedText.h"
#import "EVFlow.h"

@interface EVResponse : NSObject

@property (nonatomic, strong, readwrite) NSString* sayIt;
@property (nonatomic, strong, readwrite) NSString* sessionId;
@property (nonatomic, strong, readwrite) NSString* transactionId;
@property (nonatomic, strong, readwrite) NSString* processedText;
@property (nonatomic, strong, readwrite) NSString* originalInputText;

@property (nonatomic, strong, readwrite) EVChat* chat;
@property (nonatomic, strong, readwrite) EVDialog* dialog;

//List of EVLocaion objects
@property (nonatomic, strong, readwrite) NSArray* locations;
@property (nonatomic, strong, readwrite) NSArray* altLocations;
@property (nonatomic, strong, readwrite) NSDictionary* ean;
@property (nonatomic, strong, readwrite) EVSabre* sabre;

@property (nonatomic, strong, readwrite) EVRequestAttributes* requestAttributes;
@property (nonatomic, strong, readwrite) NSDictionary* geoAttributes;

@property (nonatomic, strong, readwrite) EVFlightAttributes* flightAttributes;
@property (nonatomic, strong, readwrite) EVHotelAttributes* hotelAttributes;
@property (nonatomic, strong, readwrite) EVServiceAttributes* serviceAttributes;
@property (nonatomic, strong, readwrite) EVCruiseAttributes* cruiseAttributes;
@property (nonatomic, strong, readwrite) EVCRMAttributes* crmAttributes;

@property (nonatomic, strong, readwrite) EVTravelers* travelers;
@property (nonatomic, strong, readwrite) EVMoney* money;
@property (nonatomic, strong, readwrite) EVPNRAttributes* pnrAttributes;

@property (nonatomic, strong, readwrite) EVFlow* flow;

// List of EVWarning objects.
@property (nonatomic, strong, readwrite) NSArray* warnings;
@property (nonatomic, strong, readwrite) EVParsedText* parsedText;
@property (nonatomic, strong, readwrite) NSArray* sessionText;

@property (nonatomic, assign, readwrite) BOOL isNewSession;

@property (nonatomic, strong, readwrite) NSDictionary* rawResponse;

- (instancetype)initWithResponse:(NSDictionary*)response;

@end
