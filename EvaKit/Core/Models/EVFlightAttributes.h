//
//  EVFlightAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int16_t, EVFlightAttributesSeatType) {
    EVFlightAttributesSeatTypeUnknown = -1,
    EVFlightAttributesSeatTypeWindow = 0,
    EVFlightAttributesSeatTypeAisle
};

typedef NS_ENUM(int16_t, EVFlightAttributesSeatClass) {
    EVFlightAttributesSeatClassUnknown = -1,
    EVFlightAttributesSeatClassFirst = 0,
    EVFlightAttributesSeatClassBusiness,
    EVFlightAttributesSeatClassPremium,
    EVFlightAttributesSeatClassEconomy
};

@interface EVFlightAttributes : NSObject

@property (nonatomic, assign, readwrite) BOOL nonstop; // A Non stop flight - Boolean attribute.
@property (nonatomic, assign, readwrite) BOOL redeye; // A Red eye flight - Boolean attribute.
@property (nonatomic, assign, readwrite) BOOL only; // The request is specifically asking for just-a-flight (and no hotel, car etc.) - Boolean
// attribute
@property (nonatomic, assign, readwrite) BOOL oneWay; // Specific request for one way trip. Example: ???????united airlines one way flights to ny????????
@property (nonatomic, assign, readwrite) BOOL twoWay; // Specific request for round trip. Example: ???????3 ticket roundtrip from tagbilaran to manila/
// 1/26/2011-1/30/2011????????
@property (nonatomic, strong, readwrite) NSArray* airlines;
@property (nonatomic, strong, readwrite) NSString* food;

@property (nonatomic, assign, readwrite) EVFlightAttributesSeatType seatType;

// List of NSNumbers with EVFlightAttributesSeatClass values.
@property (nonatomic, strong, readwrite) NSArray* seatClass;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
