//
//  EVFlightAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

typedef NS_ENUM(int16_t, EVFlightPageType) {
    EVFlightPageTypeUnknown = -1,
    EVFlightPageTypeItinerary = 0,
    EVFlightPageTypeGate,
    EVFlightPageTypeBoardingPass,
    EVFlightPageTypeDepartureTime,
    EVFlightPageTypeArrivalTime,
    EVFlightPageTypeBoardingTime
};

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

typedef NS_ENUM(int16_t, EVFlightAttributesFoodType) {
    EVFlightAttributesFoodTypeUnknown = -1,
    // Religious:
    EVFlightAttributesFoodTypeKosher = 0,
    EVFlightAttributesFoodTypeGlattKosher,
    EVFlightAttributesFoodTypeMuslim,
    EVFlightAttributesFoodTypeHindu,
    // Vegetarian:
    EVFlightAttributesFoodTypeVegetarian,
    EVFlightAttributesFoodTypeVegan,
    EVFlightAttributesFoodTypeIndianVegetarian,
    EVFlightAttributesFoodTypeRawVegetarian,
    EVFlightAttributesFoodTypeOrientalVegetarian,
    EVFlightAttributesFoodTypeLactoOvoVegetarian,
    EVFlightAttributesFoodTypeLactoVegetarian,
    EVFlightAttributesFoodTypeOvoVegetarian,
    EVFlightAttributesFoodTypeJainVegetarian,
    // Medical meals:
    EVFlightAttributesFoodTypeBland,
    EVFlightAttributesFoodTypeDiabetic,
    EVFlightAttributesFoodTypeFruitPlatter,
    EVFlightAttributesFoodTypeGlutenFree,
    EVFlightAttributesFoodTypeLowSodium,
    EVFlightAttributesFoodTypeLowCalorie,
    EVFlightAttributesFoodTypeLowFat,
    EVFlightAttributesFoodTypeLowFibre,
    EVFlightAttributesFoodTypeNonCarbohydrate,
    EVFlightAttributesFoodTypeNonLactose,
    EVFlightAttributesFoodTypeSoftFluid,
    EVFlightAttributesFoodTypeSemiFluid,
    EVFlightAttributesFoodTypeUlcerDiet,
    EVFlightAttributesFoodTypeNutFree,
    EVFlightAttributesFoodTypeLowPurine,
    EVFlightAttributesFoodTypeLowProtein,
    EVFlightAttributesFoodTypeHighFibre,
    // Infant and child:
    EVFlightAttributesFoodTypeBaby,
    EVFlightAttributesFoodTypePostWeaning,
    EVFlightAttributesFoodTypeChild, // In airline jargon, baby and infant < 2 years. 1 year < Toddler < 3 years.
    // Other:
    EVFlightAttributesFoodTypeSeafood,
    EVFlightAttributesFoodTypeJapanese
};


@interface EVFlightAttributes : NSObject

@property (nonatomic, assign, readwrite) EVBool nonstop; // A Non stop flight - Boolean attribute.
@property (nonatomic, assign, readwrite) EVBool redeye; // A Red eye flight - Boolean attribute.
@property (nonatomic, assign, readwrite) EVBool only; // The request is specifically asking for just-a-flight (and no hotel, car etc.) - Boolean
// attribute
@property (nonatomic, assign, readwrite) EVBool oneWay; // Specific request for one way trip. Example: ???????united airlines one way flights to ny????????
@property (nonatomic, assign, readwrite) EVBool twoWay; // Specific request for round trip. Example: ???????3 ticket roundtrip from tagbilaran to manila/
// 1/26/2011-1/30/2011????????
@property (nonatomic, strong, readwrite) NSArray* airlines;
@property (nonatomic, assign, readwrite) EVFlightAttributesFoodType food;

@property (nonatomic, assign, readwrite) EVFlightAttributesSeatType seatType;

// List of NSNumbers with EVFlightAttributesSeatClass values.
@property (nonatomic, strong, readwrite) NSArray* seatClass;

- (instancetype)initWithResponse:(NSDictionary *)response;
+ (EVFlightPageType)stringToPageType:(NSString*)pageName;

@end
