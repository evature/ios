//
//  EVLocation.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVLocation.h"

@implementation EVLocation

static NSDictionary* typeKeys = nil;

+ (void)load {
    typeKeys = [@{@"Continent": @(EVLocationTypeContinent),
                  @"City": @(EVLocationTypeCity),
                  @"Airport": @(EVLocationTypeAirport),
                  @"Country": @(EVLocationTypeCountry),
                  @"Area": @(EVLocationTypeArea),
                  @"State": @(EVLocationTypeState),
                  @"Property": @(EVLocationTypeProperty),
                  @"Company": @(EVLocationTypeCompany),
                  @"Chain": @(EVLocationTypeChain),
                  @"Postal_Code": @(EVLocationTypePostalCode),
                  @"Address": @(EVLocationTypeAddress),
                  @"Island": @(EVLocationTypeIsland),
                  @"Landmark": @(EVLocationTypeLandmark),
                  @"Generic_Location": @(EVLocationTypeGenericLocation),
                  @"Sea": @(EVLocationTypeSea),
                  @"_Landmark_subtype_": @(EVLocationTypeLandmark_subtype_),
                  @"Agricultural_Facility": @(EVLocationTypeAgriculturalFacility),
                  @"Airfield": @(EVLocationTypeAirfield),
                  @"Amphitheater": @(EVLocationTypeAmphitheater),
                  @"Amusement_Park": @(EVLocationTypeAmusementPark),
                  @"Ancient_Site": @(EVLocationTypeAncientSite),
                  @"Arch": @(EVLocationTypeArch),
                  @"Athletic_Field": @(EVLocationTypeAthleticField),
                  @"Bridge": @(EVLocationTypeBridge),
                  @"Building": @(EVLocationTypeBuilding),
                  @"Boundary_Marker": @(EVLocationTypeBoundaryMarker),
                  @"Battlefield": @(EVLocationTypeBattlefield),
                  @"Bus_Station": @(EVLocationTypeBusStation),
                  @"Church": @(EVLocationTypeChurch),
                  @"Cemetery": @(EVLocationTypeCemetery),
                  @"Communication_Center": @(EVLocationTypeCommunicationCenter),
                  @"Casino": @(EVLocationTypeCasino),
                  @"Castle": @(EVLocationTypeCastle),
                  @"Courthouse": @(EVLocationTypeCourthouse),
                  @"Business_Center": @(EVLocationTypeBusinessCenter),
                  @"Community_Center": @(EVLocationTypeCommunityCenter),
                  @"Facility_Center": @(EVLocationTypeFacilityCenter),
                  @"Medical_Center": @(EVLocationTypeMedicalCenter),
                  @"Convent": @(EVLocationTypeConvent),
                  @"Dam": @(EVLocationTypeDam),
                  @"Diplomatic_Facility": @(EVLocationTypeDiplomaticFacility),
                  @"Estate": @(EVLocationTypeEstate),
                  @"Facility": @(EVLocationTypeFacility),
                  @"Farm": @(EVLocationTypeFarm),
                  @"Farmstead": @(EVLocationTypeFarmstead),
                  @"Fort": @(EVLocationTypeFort),
                  @"Gate": @(EVLocationTypeGate),
                  @"Garden": @(EVLocationTypeGarden),
                  @"House": @(EVLocationTypeHouse),
                  @"Country_House": @(EVLocationTypeCountryHouse),
                  @"Hospital": @(EVLocationTypeHospital),
                  @"Historical_Site": @(EVLocationTypeHistoricalSite),
                  @"Hotel": @(EVLocationTypeHotel),
                  @"Military_Installation": @(EVLocationTypeMilitaryInstallation),
                  @"Research_Institue": @(EVLocationTypeResearchInstitue),
                  @"Library": @(EVLocationTypeLibrary),
                  @"Lighthouse": @(EVLocationTypeLighthouse),
                  @"Shopping_Mall": @(EVLocationTypeShoppingMall),
                  @"Brewery": @(EVLocationTypeBrewery),
                  @"Abandoned_Factory": @(EVLocationTypeAbandonedFactory),
                  @"Military_Base": @(EVLocationTypeMilitaryBase),
                  @"Market": @(EVLocationTypeMarket),
                  @"Mine": @(EVLocationTypeMine),
                  @"Chrome_Mine": @(EVLocationTypeChromeMine),
                  @"Monument": @(EVLocationTypeMonument),
                  @"Mosque": @(EVLocationTypeMosque),
                  @"Mission": @(EVLocationTypeMission),
                  @"Abandoned_Mission": @(EVLocationTypeAbandonedMission),
                  @"Monastery": @(EVLocationTypeMonastery),
                  @"Metro": @(EVLocationTypeMetro),
                  @"Museum": @(EVLocationTypeMuseum),
                  @"Observation_Point": @(EVLocationTypeObservationPoint),
                  @"Observatory": @(EVLocationTypeObservatory),
                  @"Radio_Observatory": @(EVLocationTypeRadioObservatory),
                  @"Opera_House": @(EVLocationTypeOperaHouse),
                  @"Palace": @(EVLocationTypePalace),
                  @"Pagoda": @(EVLocationTypePagoda),
                  @"Pool": @(EVLocationTypePool),
                  @"Power_Station": @(EVLocationTypePowerStation),
                  @"Border_Post": @(EVLocationTypeBorderPost),
                  @"Point": @(EVLocationTypePoint),
                  @"Pyramid": @(EVLocationTypePyramid),
                  @"Golf_Course": @(EVLocationTypeGolfCourse),
                  @"Race_Track": @(EVLocationTypeRaceTrack),
                  @"Restaurant": @(EVLocationTypeRestaurant),
                  @"Religious_Site": @(EVLocationTypeReligiousSite),
                  @"Ranch": @(EVLocationTypeRanch),
                  @"Resort": @(EVLocationTypeResort),
                  @"Railway_Station": @(EVLocationTypeRailwayStation),
                  @"Railroad_Stop": @(EVLocationTypeRailroadStop),
                  @"Ruin": @(EVLocationTypeRuin),
                  @"Railroad_Yard": @(EVLocationTypeRailroadYard),
                  @"School": @(EVLocationTypeSchool),
                  @"College": @(EVLocationTypeCollege),
                  @"Military_School": @(EVLocationTypeMilitarySchool),
                  @"Technical_School": @(EVLocationTypeTechnicalSchool),
                  @"Shrine": @(EVLocationTypeShrine),
                  @"Stadium": @(EVLocationTypeStadium),
                  @"Meteorological_Station": @(EVLocationTypeMeteorologicalStation),
                  @"Theater": @(EVLocationTypeTheater),
                  @"Tomb": @(EVLocationTypeTomb),
                  @"Temple": @(EVLocationTypeTemple),
                  @"Tower": @(EVLocationTypeTower),
                  @"Transit_Terminal": @(EVLocationTypeTransitTerminal),
                  @"Triangulation_Station": @(EVLocationTypeTriangulationStation),
                  @"University_Prep_School": @(EVLocationTypeUniversityPrepSchool),
                  @"University": @(EVLocationTypeUniversity),
                  @"Veterinary_Facility": @(EVLocationTypeVeterinaryFacility),
                  @"Wall": @(EVLocationTypeWall),
                  @"Zoo": @(EVLocationTypeZoo)
                  } retain];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.index = [[response objectForKey:@"Index"] unsignedIntegerValue];
        if ([response objectForKey:@"Next"] != nil) {
            self.next = [[response objectForKey:@"Next"] integerValue];
        } else {
            self.next = -1;
        }
        self.allAirportCode = [response objectForKey:@"All Airports Code"];
        if ([response objectForKey:@"Geoid"] != nil) {
            self.geoId = [NSString stringWithFormat:@"%@", [response objectForKey:@"Geoid"]];
        }
        if ([response objectForKey:@"Actions"] != nil) {
            self.actions = [NSSet setWithArray:[response objectForKey:@"Actions"]];
        }
        self.derivedFrom = [response objectForKey:@"Derived From"];
        if ([response objectForKey:@"Request Attributes"] != nil) {
            self.requestAttributes = [[[EVRequestAttributes alloc] initWithResponse:[response objectForKey:@"Request Attributes"]] autorelease];
        }
        if ([response objectForKey:@"Departure"] != nil) {
            self.departure = [[[EVTime alloc] initWithResponse:[response objectForKey:@"Departure"]] autorelease];
        }
        if ([response objectForKey:@"Arrival"] != nil) {
            self.arrival = [[[EVTime alloc] initWithResponse:[response objectForKey:@"Arrival"]] autorelease];
        }
        if ([response objectForKey:@"Stay"] != nil) {
            self.stay = [[[EVTime alloc] initWithResponse:[response objectForKey:@"Stay"]] autorelease];
        }
        if ([response objectForKey:@"Name"] != nil) {
            NSString* name = [response objectForKey:@"Name"];
            NSUInteger ind = [name rangeOfString:@" (GID"].location;
            if (ind != NSNotFound) {
                self.name = [name substringToIndex:ind];
            } else {
                self.name = name;
            }
        }
        if ([response objectForKey:@"Type"] != nil) {
            NSNumber* val = [typeKeys objectForKey:[[response objectForKey:@"Type"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
            if (val != nil) {
                self.type = [val intValue];
            } else {
                self.type = EVLocationTypeUnknown;
            }
        } else {
            self.type = EVLocationTypeUnknown;
        }
        self.longitude = [[response objectForKey:@"Longitude"] doubleValue];
        self.latitude = [[response objectForKey:@"Latitude"] doubleValue];
        if ([response objectForKey:@"Airports"] != nil) {
            self.airports = [[response objectForKey:@"Airports"] componentsSeparatedByString:@","];
        }
        if ([response objectForKey:@"Flight Attributes"] != nil) {
            self.flightAttributes = [[[EVFlightAttributes alloc] initWithResponse:[response objectForKey:@"Flight Attributes"]] autorelease];
        }
        if ([response objectForKey:@"Hotel Attributes"] != nil) {
            self.hotelAttributes = [[[EVHotelAttributes alloc] initWithResponse:[response objectForKey:@"Hotel Attributes"]] autorelease];
        }
        if ([response objectForKey:@"Purpose"] != nil) {
            self.purpose = [NSSet setWithArray:[response objectForKey:@"Purpose"]];
        }
        if ([response objectForKey:@"Keys"] != nil) {
            self.keys = [response objectForKey:@"Keys"];
        }
        if ([response objectForKey:@"Nearest Customer Location"] != nil) {
            self.nearestCustomerLocation = [[[EVLocation alloc] initWithResponse:[response objectForKey:@"Nearest Customer Location"]] autorelease];
        }
    }
    return self;
}

- (NSString*)airportCode {
    if (self.allAirportCode != nil) {
        return self.allAirportCode;
    }
    if ([self.airports count] > 0) {
        return [self.airports objectAtIndex:0];
    }
    return nil;
}
- (BOOL)isTransit {
    return self.purpose != nil && [self.purpose containsObject:@"Transit"];
}
- (BOOL)isHotelSearch {
    return self.actions != nil && [self.actions containsObject:@"Get Accommodation"];
    
}
- (BOOL)isDestination {
    return self.actions != nil && [self.actions containsObject:@"Get There"];
}

- (void)dealloc {
    self.allAirportCode = nil;
    self.airports = nil;
    self.geoId = nil;
    self.actions = nil;
    
    self.requestAttributes = nil;
    self.name = nil;
    self.departure = nil;
    self.arrival = nil;
    self.stay = nil;
    self.purpose = nil;
    self.derivedFrom = nil;
    
    self.hotelAttributes = nil;
    self.flightAttributes = nil;
    
    self.keys = nil;
    self.nearestCustomerLocation = nil;
    [super dealloc];
}

@end
