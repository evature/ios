//
//  EVHotelAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVHotelAttributes.h"

@implementation EVHotelChain

- (instancetype)initWithResponse:(id)response {
    self = [super init];
    if (self != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            _name = [response objectForKey:@"Name"];
            _simpleName = [response objectForKey:@"simple_name"];
            _gdsCode = [response objectForKey:@"gds_code"];
            _evaCode = [response objectForKey:@"eva_code"];
        } else {
            _name = response;
        }
    }
    return self;
}

- (void)dealloc {
    _name = nil;
    _simpleName = nil;
    _gdsCode = nil;
    _evaCode = nil;
    [super dealloc];
}

@end


@implementation EVHotelAttributes

static NSDictionary* amenitiesKeys = nil;
static NSDictionary* poolKeys = nil;
static NSDictionary* accomodationKeys = nil;

+ (void)load {
    poolKeys = [@{@"Any": @(EVHotelAttributesPoolTypeAny),
                  @"Indoor": @(EVHotelAttributesPoolTypeIndoor),
                  @"Outdoor": @(EVHotelAttributesPoolTypeOutdoor)
                  } retain];

    amenitiesKeys  =  [@{@"Child Free": @(EVHotelAttributesAmentitiesChildFree),
                          @"Business": @(EVHotelAttributesAmentitiesBusiness),
                          @"Airport Shuttle": @(EVHotelAttributesAmentitiesAirportShuttle),
                          @"Casino": @(EVHotelAttributesAmentitiesCasino),
                          @"Fishing": @(EVHotelAttributesAmentitiesFishing),
                          @"Snow Conditions": @(EVHotelAttributesAmentitiesSnowConditions),
                          @"Snorkeling": @(EVHotelAttributesAmentitiesSnorkeling),
                          @"Diving": @(EVHotelAttributesAmentitiesDiving),
                          @"Activity": @(EVHotelAttributesAmentitiesActivity),
                          @"Ski": @(EVHotelAttributesAmentitiesSki),
                          @"Ski In/Out": @(EVHotelAttributesAmentitiesSkiInOut),
                          @"Golf": @(EVHotelAttributesAmentitiesGolf),
                          @"Kids for free": @(EVHotelAttributesAmentitiesKidsForFree),
                          @"City": @(EVHotelAttributesAmentitiesCity),
                          @"Family": @(EVHotelAttributesAmentitiesFamily),
                          @"Pet Friendly": @(EVHotelAttributesAmentitiesPetFriendly),
                          @"Romantic": @(EVHotelAttributesAmentitiesRomantic),
                          @"Adventure": @(EVHotelAttributesAmentitiesAdventure),
                          @"Designer": @(EVHotelAttributesAmentitiesDesigner),
                          @"Gym": @(EVHotelAttributesAmentitiesGym),
                          @"Quiet": @(EVHotelAttributesAmentitiesQuiet),
                          @"Meeting Room": @(EVHotelAttributesAmentitiesMeetingRoom),
                          @"Restaurant": @(EVHotelAttributesAmentitiesRestaurant),
                          @"Gourmet": @(EVHotelAttributesAmentitiesGourmet),
                          @"Disabled": @(EVHotelAttributesAmentitiesDisabled),
                          @"Spa": @(EVHotelAttributesAmentitiesSpa),
                          @"Castle": @(EVHotelAttributesAmentitiesCastle),
                          @"Sport": @(EVHotelAttributesAmentitiesSport),
                          @"Countryside": @(EVHotelAttributesAmentitiesCountryside)
                          } retain];
    
    accomodationKeys = [@{@"Chalet": @(EVHotelAttributesAccommodationTypeChalet),
                          @"Villa": @(EVHotelAttributesAccommodationTypeVilla),
                          @"Apartment": @(EVHotelAttributesAccommodationTypeApartment),
                          @"Motel": @(EVHotelAttributesAccommodationTypeMotel),
                          @"Camping": @(EVHotelAttributesAccommodationTypeCamping),
                          @"Hostel": @(EVHotelAttributesAccommodationTypeHostel),
                          @"Mobile Home": @(EVHotelAttributesAccommodationTypeMobileHome),
                          @"Guest House": @(EVHotelAttributesAccommodationTypeGuestHouse),
                          @"Holiday Village": @(EVHotelAttributesAccommodationTypeHolidayVillage),
                          @"Hotel Residence": @(EVHotelAttributesAccommodationTypeHotelResidence),
                          @"Guest Accommodations": @(EVHotelAttributesAccommodationTypeGuestAccommodations),
                          @"Resort": @(EVHotelAttributesAccommodationTypeResort),
                          @"Hotel": @(EVHotelAttributesAccommodationTypeHotel),
                          @"Zimmer": @(EVHotelAttributesAccommodationTypeZimmer),
                          @"Farm": @(EVHotelAttributesAccommodationTypeFarm),
                          @"Youth Hostel": @(EVHotelAttributesAccommodationTypeYouthHostel),
                          @"Bungalow": @(EVHotelAttributesAccommodationTypeBungalow),
                          @"Inn": @(EVHotelAttributesAccommodationTypeInn)} retain];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _selfCatering = EVBoolNotSet;
        _bedAndBreakfast = EVBoolNotSet;
        _halfBoard = EVBoolNotSet;
        _fullBoard = EVBoolNotSet;
        _allInclusive = EVBoolNotSet;
        _drinksInclusive = EVBoolNotSet;
        _parkingFacilities = EVBoolNotSet;
        _parkingValet = EVBoolNotSet;
        _parkingFree = EVBoolNotSet;
        _accommodationType = EVHotelAttributesAccommodationTypeUnknown;
        _poolType = EVHotelAttributesPoolTypeUnknown;
        _minStars = -1;
        _maxStars = -1;
        
    }
    return self;
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        
        _selfCatering = EVBoolNotSet;
        _bedAndBreakfast = EVBoolNotSet;
        _halfBoard = EVBoolNotSet;
        _fullBoard = EVBoolNotSet;
        _allInclusive = EVBoolNotSet;
        _drinksInclusive = EVBoolNotSet;
        _parkingFacilities = EVBoolNotSet;
        _parkingValet = EVBoolNotSet;
        _parkingFree = EVBoolNotSet;
        _minStars = -1;
        _maxStars = -1;
        
        if ([response objectForKey:@"Chain"] != nil) {
            id object = [response objectForKey:@"Chain"];
            if ([object isKindOfClass:[NSArray class]]) {
                NSMutableArray* chain = [NSMutableArray array];
                for (NSDictionary* elem in object) {
                    [chain addObject:[[[EVHotelChain alloc] initWithResponse:elem] autorelease]];
                }
                _chains = [NSArray arrayWithArray:chain];
            } else {
                _chains = [NSArray arrayWithObject:[[[EVHotelChain alloc] initWithResponse:object] autorelease]];
            }
        } else {
            _chains = [NSArray array];
        }
        
        NSArray* board = [response objectForKey:@"Board"];
        if (board != nil) {
            if ([board containsObject:@"Self Catering"]) {
                _selfCatering = EV_TRUE;
            }
            if ([board containsObject:@"Bed and Breakfast"]) {
                _bedAndBreakfast = EV_TRUE;
            }
            if ([board containsObject:@"Half Board"]) {
                _halfBoard = EV_TRUE;
            }
            if ([board containsObject:@"Full Board"]) {
                _fullBoard = EV_TRUE;
            }
            if ([board containsObject:@"All Inclusive"]) {
                _allInclusive = EV_TRUE;
            }
            if ([board containsObject:@"Drinks Inclusive"]) {
                _drinksInclusive = EV_TRUE;
            }
        }
        
        if ([response objectForKey:@"Quality"] != nil) {
            NSArray* quality = [response objectForKey:@"Quality"];
            _minStars = [[quality objectAtIndex:0] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:0] integerValue];
            _maxStars = [[quality objectAtIndex:1] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:1] integerValue];
        }
        if ([response objectForKey:@"Pool"] != nil) {
            NSNumber* val = [poolKeys objectForKey:[response objectForKey:@"Pool"]];
            if (val != nil) {
                _poolType = [val shortValue];
            } else {
                _poolType = EVHotelAttributesPoolTypeUnknown;
            }
        } else {
            _poolType = EVHotelAttributesPoolTypeUnknown;
        }
        if ([response objectForKey:@"Accommodation Type"] != nil) {
            NSNumber* val = [accomodationKeys objectForKey:[response objectForKey:@"Accommodation Type"]];
            if (val != nil) {
                _accommodationType = [val shortValue];
            } else {
                _accommodationType = EVHotelAttributesAccommodationTypeUnknown;
            }
        } else {
            _accommodationType = EVHotelAttributesAccommodationTypeUnknown;
        }
        if ([response objectForKey:@"Parking"] != nil) {
            NSDictionary* parking = [response objectForKey:@"Parking"];
            _parkingFacilities = [parking objectForKey:@"Facilities"] != nil ?[[parking objectForKey:@"Facilities"] boolValue] : EVBoolNotSet;
            _parkingValet = [parking objectForKey:@"Valet"] != nil ? [[parking objectForKey:@"Valet"] boolValue] : EVBoolNotSet;
            _parkingFree = [parking objectForKey:@"Free"]  != nil ? [[parking objectForKey:@"Free"] boolValue] : EVBoolNotSet;
        }
        NSMutableArray* amenities = [NSMutableArray array];
        for (NSString* ament in [amenitiesKeys allKeys]) {
            if ([[response objectForKey:ament] boolValue]) {
                [amenities addObject:[amenitiesKeys objectForKey:ament]];
            }
        }
        _amenities = [NSSet setWithArray:amenities];
    }
    return self;
}

- (void)dealloc {
    _amenities = nil;
    _chains = nil;
    [super dealloc];
}

@end
