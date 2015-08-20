//
//  EVCruiseAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property (nonatomic, assign, readwrite) BOOL family;
@property (nonatomic, assign, readwrite) BOOL romantic;
@property (nonatomic, assign, readwrite) BOOL adventure;
@property (nonatomic, assign, readwrite) BOOL childFree; // adult only
@property (nonatomic, assign, readwrite) BOOL yacht;
@property (nonatomic, assign, readwrite) BOOL barge;
@property (nonatomic, assign, readwrite) BOOL sailingShip;
@property (nonatomic, assign, readwrite) BOOL riverCruise;
@property (nonatomic, assign, readwrite) BOOL forSingles;
@property (nonatomic, assign, readwrite) BOOL forGays;
@property (nonatomic, assign, readwrite) BOOL steamboat;
@property (nonatomic, assign, readwrite) BOOL petFriendly;
@property (nonatomic, assign, readwrite) BOOL yoga;
@property (nonatomic, assign, readwrite) BOOL landTour;
@property (nonatomic, assign, readwrite) BOOL oneWay;

@property (nonatomic, assign, readwrite) EVCruiseAttributesBoardType board;
@property (nonatomic, assign, readwrite) NSInteger minStars;
@property (nonatomic, assign, readwrite) NSInteger maxStars;

@property (nonatomic, assign, readwrite) EVCruiseAttributesShipSize shipSize;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
