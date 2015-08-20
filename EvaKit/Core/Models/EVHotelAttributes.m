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

@end


@implementation EVHotelAttributes

static NSDictionary* amentitiesKeys = nil;
static NSDictionary* poolKeys = nil;
static NSDictionary* accomodationKeys = nil;

+ (void)load {
    poolKeys = [@{@"Any": @(EVHotelAttributesPoolTypeAny),
                  @"Indoor": @(EVHotelAttributesPoolTypeIndoor),
                  @"Outdoor": @(EVHotelAttributesPoolTypeOutdoor)
                  } retain];

    amentitiesKeys  =  [@{@"Child Free": @(EVHotelAttributesAmentitiesChildFree),
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
        self.selfCatering = [board containsObject:@"Self Catering"];
        self.bedAndBreakfast = [board containsObject:@"Bed and Breakfast"];
        self.halfBoard = [board containsObject:@"Half Board"];
        self.fullBoard = [board containsObject:@"Full Board"];
        self.allInclusive = [board containsObject:@"All Inclusive"];
        self.drinksInclusive = [board containsObject:@"Drinks Inclusive"];
        
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
            self.parkingFacilities = [[parking objectForKey:@"Facilities"] boolValue];
            self.parkingValet = [[parking objectForKey:@"Valet"] boolValue];
            self.parkingFree = [[parking objectForKey:@"Free"] boolValue];
        }
        NSMutableArray* amentities = [NSMutableArray array];
        for (NSString* ament in [amentitiesKeys allKeys]) {
            if ([[response objectForKey:ament] boolValue]) {
                [amentities addObject:[amentitiesKeys objectForKey:ament]];
            }
        }
        self.amentities = [NSSet setWithArray:amentities];
    }
    return self;
}

@end
