//
//  EVHotelAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

@interface EVHotelChain : NSObject

@property (nonatomic, strong, readwrite) NSString* name;
@property (nonatomic, strong, readwrite) NSString* simpleName;
@property (nonatomic, strong, readwrite) NSString* gdsCode;
@property (nonatomic, strong, readwrite) NSString* evaCode;

- (instancetype)initWithResponse:(id)response;

@end


typedef NS_ENUM(int16_t, EVHotelAttributesAmentities) {
    EVHotelAttributesAmentitiesChildFree = 0,
    EVHotelAttributesAmentitiesBusiness,
    EVHotelAttributesAmentitiesAirportShuttle,
    EVHotelAttributesAmentitiesCasino,
    EVHotelAttributesAmentitiesFishing,
    EVHotelAttributesAmentitiesSnowConditions,
    EVHotelAttributesAmentitiesSnorkeling,
    EVHotelAttributesAmentitiesDiving,
    EVHotelAttributesAmentitiesActivity,
    EVHotelAttributesAmentitiesSki,
    EVHotelAttributesAmentitiesSkiInOut,
    EVHotelAttributesAmentitiesGolf,
    EVHotelAttributesAmentitiesKidsForFree,
    EVHotelAttributesAmentitiesCity,
    EVHotelAttributesAmentitiesFamily,
    EVHotelAttributesAmentitiesPetFriendly,
    EVHotelAttributesAmentitiesRomantic,
    EVHotelAttributesAmentitiesAdventure,
    EVHotelAttributesAmentitiesDesigner,
    EVHotelAttributesAmentitiesGym,
    EVHotelAttributesAmentitiesQuiet,
    EVHotelAttributesAmentitiesMeetingRoom,
    EVHotelAttributesAmentitiesRestaurant,
    EVHotelAttributesAmentitiesGourmet,
    EVHotelAttributesAmentitiesDisabled,
    EVHotelAttributesAmentitiesSpa,
    EVHotelAttributesAmentitiesCastle,
    EVHotelAttributesAmentitiesSport,
    EVHotelAttributesAmentitiesCountryside
};

typedef NS_ENUM(int16_t, EVHotelAttributesPoolType) {
    EVHotelAttributesPoolTypeUnknown = -1,
    EVHotelAttributesPoolTypeAny = 0,
    EVHotelAttributesPoolTypeIndoor,
    EVHotelAttributesPoolTypeOutdoor
};

typedef NS_ENUM(int16_t, EVHotelAttributesAccommodationType) {
    EVHotelAttributesAccommodationTypeUnknown = -1,
    EVHotelAttributesAccommodationTypeChalet = 0,
    EVHotelAttributesAccommodationTypeVilla,
    EVHotelAttributesAccommodationTypeApartment,
    EVHotelAttributesAccommodationTypeMotel,
    EVHotelAttributesAccommodationTypeCamping,
    EVHotelAttributesAccommodationTypeHostel,
    EVHotelAttributesAccommodationTypeMobileHome,
    EVHotelAttributesAccommodationTypeGuestHouse,
    EVHotelAttributesAccommodationTypeHolidayVillage,
    EVHotelAttributesAccommodationTypeHotelResidence,
    EVHotelAttributesAccommodationTypeGuestAccommodations,
    EVHotelAttributesAccommodationTypeResort,
    EVHotelAttributesAccommodationTypeHotel,
    EVHotelAttributesAccommodationTypeZimmer,
    EVHotelAttributesAccommodationTypeFarm,
    EVHotelAttributesAccommodationTypeYouthHostel,
    EVHotelAttributesAccommodationTypeBungalow,
    EVHotelAttributesAccommodationTypeInn
};

@interface EVHotelAttributes : NSObject

// List of EVHotelChain objects
@property (nonatomic, strong, readwrite) NSArray* chains;

@property (nonatomic, assign, readwrite) EVBool selfCatering;
@property (nonatomic, assign, readwrite) EVBool bedAndBreakfast;
@property (nonatomic, assign, readwrite) EVBool halfBoard;
@property (nonatomic, assign, readwrite) EVBool fullBoard;
@property (nonatomic, assign, readwrite) EVBool allInclusive;
@property (nonatomic, assign, readwrite) EVBool drinksInclusive;

@property (nonatomic, assign, readwrite) NSInteger minStars;
@property (nonatomic, assign, readwrite) NSInteger maxStars;

// Set of NSNumbers with EVHotelAttributesAmentities values.
@property (nonatomic, strong, readwrite) NSSet* amenities;

@property (nonatomic, assign, readwrite) EVHotelAttributesPoolType poolType;
@property (nonatomic, assign, readwrite) EVHotelAttributesAccommodationType accommodationType;

@property (nonatomic, assign, readwrite) EVBool parkingFacilities;
@property (nonatomic, assign, readwrite) EVBool parkingValet;
@property (nonatomic, assign, readwrite) EVBool parkingFree;

// TODO: Rooms
// TODO: Ski

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
