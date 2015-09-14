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
            self.name = [response objectForKey:@"Name"];
            self.simpleName = [response objectForKey:@"simple_name"];
            self.gdsCode = [response objectForKey:@"gds_code"];
            self.evaCode = [response objectForKey:@"eva_code"];
        } else {
            self.name = response;
        }
    }
    return self;
}

- (void)dealloc {
    self.name = nil;
    self.simpleName = nil;
    self.gdsCode = nil;
    self.evaCode = nil;
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

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        
        self.selfCatering = EVBoolNotSet;
        self.bedAndBreakfast = EVBoolNotSet;
        self.halfBoard = EVBoolNotSet;
        self.fullBoard = EVBoolNotSet;
        self.allInclusive = EVBoolNotSet;
        self.drinksInclusive = EVBoolNotSet;
        self.parkingFacilities = EVBoolNotSet;
        self.parkingValet = EVBoolNotSet;
        self.parkingFree = EVBoolNotSet;
        self.minStars = -1;
        self.maxStars = -1;
        
        if ([response objectForKey:@"Chain"] != nil) {
            id object = [response objectForKey:@"Chain"];
            if ([object isKindOfClass:[NSArray class]]) {
                NSMutableArray* chain = [NSMutableArray array];
                for (NSDictionary* elem in object) {
                    [chain addObject:[[[EVHotelChain alloc] initWithResponse:elem] autorelease]];
                }
                self.chains = [NSArray arrayWithArray:chain];
            } else {
                self.chains = [NSArray arrayWithObject:[[[EVHotelChain alloc] initWithResponse:object] autorelease]];
            }
        } else {
            self.chains = [NSArray array];
        }
        
        NSArray* board = [response objectForKey:@"Board"];
        if (board != nil) {
            if ([board containsObject:@"Self Catering"]) {
                self.selfCatering = EV_TRUE;
            }
            if ([board containsObject:@"Bed and Breakfast"]) {
                self.bedAndBreakfast = EV_TRUE;
            }
            if ([board containsObject:@"Half Board"]) {
                self.halfBoard = EV_TRUE;
            }
            if ([board containsObject:@"Full Board"]) {
                self.fullBoard = EV_TRUE;
            }
            if ([board containsObject:@"All Inclusive"]) {
                self.allInclusive = EV_TRUE;
            }
            if ([board containsObject:@"Drinks Inclusive"]) {
                self.drinksInclusive = EV_TRUE;
            }
        }
        
        if ([response objectForKey:@"Quality"] != nil) {
            NSArray* quality = [response objectForKey:@"Quality"];
            self.minStars = [[quality objectAtIndex:0] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:0] integerValue];
            self.maxStars = [[quality objectAtIndex:1] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:1] integerValue];
        }
        if ([response objectForKey:@"Pool"] != nil) {
            NSNumber* val = [poolKeys objectForKey:[response objectForKey:@"Pool"]];
            if (val != nil) {
                self.poolType = [val shortValue];
            } else {
                self.poolType = EVHotelAttributesPoolTypeUnknown;
            }
        } else {
            self.poolType = EVHotelAttributesPoolTypeUnknown;
        }
        if ([response objectForKey:@"Accommodation Type"] != nil) {
            NSNumber* val = [accomodationKeys objectForKey:[response objectForKey:@"Accommodation Type"]];
            if (val != nil) {
                self.accommodationType = [val shortValue];
            } else {
                self.accommodationType = EVHotelAttributesAccommodationTypeUnknown;
            }
        } else {
            self.accommodationType = EVHotelAttributesAccommodationTypeUnknown;
        }
        if ([response objectForKey:@"Parking"] != nil) {
            NSDictionary* parking = [response objectForKey:@"Parking"];
            self.parkingFacilities = [parking objectForKey:@"Facilities"] != nil ?[[parking objectForKey:@"Facilities"] boolValue] : EVBoolNotSet;
            self.parkingValet = [parking objectForKey:@"Valet"] != nil ? [[parking objectForKey:@"Valet"] boolValue] : EVBoolNotSet;
            self.parkingFree = [parking objectForKey:@"Free"]  != nil ? [[parking objectForKey:@"Free"] boolValue] : EVBoolNotSet;
        }
        NSMutableArray* amenities = [NSMutableArray array];
        for (NSString* ament in [amenitiesKeys allKeys]) {
            if ([[response objectForKey:ament] boolValue]) {
                [amenities addObject:[amenitiesKeys objectForKey:ament]];
            }
        }
        self.amenities = [NSSet setWithArray:amenities];
    }
    return self;
}

- (void)dealloc {
    self.amenities = nil;
    self.chains = nil;
    [super dealloc];
}

@end
