//
//  EVCruiseAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

@interface EVCruiseline : NSObject

@property (nonatomic, strong, readwrite) NSString* name;
@property (nonatomic, strong, readwrite) NSString* key;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end

@interface EVCruiseship : NSObject

@property (nonatomic, strong, readwrite) NSString* name;
@property (nonatomic, strong, readwrite) NSString* key;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end

typedef NS_ENUM(int16_t, EVCruiseAttributesCabinType) {
    EVCruiseAttributesCabinTypeOther = -1,
    EVCruiseAttributesCabinTypeWindowless = 0,
    EVCruiseAttributesCabinTypeRegularCabin,
    EVCruiseAttributesCabinTypeBalcony,
    EVCruiseAttributesCabinTypePortHole,
    EVCruiseAttributesCabinTypePicture,
    EVCruiseAttributesCabinTypeFullWall,
    EVCruiseAttributesCabinTypeInternal,
    EVCruiseAttributesCabinTypeOceanview,
    EVCruiseAttributesCabinTypeWindow,
    EVCruiseAttributesCabinTypeExternal,
    EVCruiseAttributesCabinTypeSuite,
    EVCruiseAttributesCabinTypeCabin,
    EVCruiseAttributesCabinTypeMiniSuite,
    EVCruiseAttributesCabinTypeFamilySuite,
    EVCruiseAttributesCabinTypePresidentialSuite
};

typedef NS_ENUM(int16_t, EVCruiseAttributesPoolType) {
    EVCruiseAttributesPoolTypeOther = -1,
    EVCruiseAttributesPoolTypeAny = 0,
    EVCruiseAttributesPoolTypeIndoor,
    EVCruiseAttributesPoolTypeOutdoor,
    EVCruiseAttributesPoolTypeChildren
};

typedef NS_ENUM(int16_t, EVCruiseAttributesBoardType) {
    EVCruiseAttributesBoardTypeOther = -1,
    EVCruiseAttributesBoardTypeFullBoard = 0,
    EVCruiseAttributesBoardTypeAllInclusive
};

typedef NS_ENUM(int16_t, EVCruiseAttributesShipSize) {
    EVCruiseAttributesShipSizeOther = -1,
    EVCruiseAttributesShipSizeSmall = 0,
    EVCruiseAttributesShipSizeMedium,
    EVCruiseAttributesShipSizeLarge
};

@interface EVCruiseAttributes : NSObject

@property (nonatomic, strong, readwrite) NSArray* cruiselines;
@property (nonatomic, strong, readwrite) NSArray* cruiseships;

@property (nonatomic, assign, readwrite) EVCruiseAttributesCabinType cabin;
@property (nonatomic, assign, readwrite) EVCruiseAttributesPoolType pool;

@property (nonatomic, assign, readwrite) EVBool family;
@property (nonatomic, assign, readwrite) EVBool romantic;
@property (nonatomic, assign, readwrite) EVBool adventure;
@property (nonatomic, assign, readwrite) EVBool childFree; // adult only
@property (nonatomic, assign, readwrite) EVBool yacht;
@property (nonatomic, assign, readwrite) EVBool barge;
@property (nonatomic, assign, readwrite) EVBool sailingShip;
@property (nonatomic, assign, readwrite) EVBool riverCruise;
@property (nonatomic, assign, readwrite) EVBool forSingles;
@property (nonatomic, assign, readwrite) EVBool forGays;
@property (nonatomic, assign, readwrite) EVBool steamboat;
@property (nonatomic, assign, readwrite) EVBool petFriendly;
@property (nonatomic, assign, readwrite) EVBool yoga;
@property (nonatomic, assign, readwrite) EVBool landTour;
@property (nonatomic, assign, readwrite) EVBool oneWay;

@property (nonatomic, assign, readwrite) EVCruiseAttributesBoardType board;
@property (nonatomic, assign, readwrite) NSInteger minStars;
@property (nonatomic, assign, readwrite) NSInteger maxStars;

@property (nonatomic, assign, readwrite) EVCruiseAttributesShipSize shipSize;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
