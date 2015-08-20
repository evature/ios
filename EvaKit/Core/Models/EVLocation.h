//
//  EVLocation.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVRequestAttributes.h"
#import "EVTime.h"
#import "EVHotelAttributes.h"
#import "EVFlightAttributes.h"

typedef NS_ENUM(int, EVLocationType) {
    EVLocationTypeUnknown = -1,
    EVLocationTypeContinent = 0,
    EVLocationTypeCity,
    EVLocationTypeAirport,
    EVLocationTypeCountry,
    EVLocationTypeArea,
    EVLocationTypeState,
    EVLocationTypeProperty,
    EVLocationTypeCompany,
    EVLocationTypeChain,
    EVLocationTypePostalCode,
    EVLocationTypeAddress,
    EVLocationTypeIsland,
    EVLocationTypeLandmark,
    EVLocationTypeGenericLocation,
    EVLocationTypeSea,
    EVLocationTypeLandmark_subtype_,
    EVLocationTypeAgriculturalFacility,
    EVLocationTypeAirfield,
    EVLocationTypeAmphitheater,
    EVLocationTypeAmusementPark,
    EVLocationTypeAncientSite,
    EVLocationTypeArch,
    EVLocationTypeAthleticField,
    EVLocationTypeBridge,
    EVLocationTypeBuilding,
    EVLocationTypeBoundaryMarker,
    EVLocationTypeBattlefield,
    EVLocationTypeBusStation,
    EVLocationTypeChurch,
    EVLocationTypeCemetery,
    EVLocationTypeCommunicationCenter,
    EVLocationTypeCasino,
    EVLocationTypeCastle,
    EVLocationTypeCourthouse,
    EVLocationTypeBusinessCenter,
    EVLocationTypeCommunityCenter,
    EVLocationTypeFacilityCenter,
    EVLocationTypeMedicalCenter,
    EVLocationTypeConvent,
    EVLocationTypeDam,
    EVLocationTypeDiplomaticFacility,
    EVLocationTypeEstate,
    EVLocationTypeFacility,
    EVLocationTypeFarm,
    EVLocationTypeFarmstead,
    EVLocationTypeFort,
    EVLocationTypeGate,
    EVLocationTypeGarden,
    EVLocationTypeHouse,
    EVLocationTypeCountryHouse,
    EVLocationTypeHospital,
    EVLocationTypeHistoricalSite,
    EVLocationTypeHotel,
    EVLocationTypeMilitaryInstallation,
    EVLocationTypeResearchInstitue,
    EVLocationTypeLibrary,
    EVLocationTypeLighthouse,
    EVLocationTypeShoppingMall,
    EVLocationTypeBrewery,
    EVLocationTypeAbandonedFactory,
    EVLocationTypeMilitaryBase,
    EVLocationTypeMarket,
    EVLocationTypeMine,
    EVLocationTypeChromeMine,
    EVLocationTypeMonument,
    EVLocationTypeMosque,
    EVLocationTypeMission,
    EVLocationTypeAbandonedMission,
    EVLocationTypeMonastery,
    EVLocationTypeMetro,
    EVLocationTypeMuseum,
    EVLocationTypeObservationPoint,
    EVLocationTypeObservatory,
    EVLocationTypeRadioObservatory,
    EVLocationTypeOperaHouse,
    EVLocationTypePalace,
    EVLocationTypePagoda,
    EVLocationTypePool,
    EVLocationTypePowerStation,
    EVLocationTypeBorderPost,
    EVLocationTypePoint,
    EVLocationTypePyramid,
    EVLocationTypeGolfCourse,
    EVLocationTypeRaceTrack,
    EVLocationTypeRestaurant,
    EVLocationTypeReligiousSite,
    EVLocationTypeRanch,
    EVLocationTypeResort,
    EVLocationTypeRailwayStation,
    EVLocationTypeRailroadStop,
    EVLocationTypeRuin,
    EVLocationTypeRailroadYard,
    EVLocationTypeSchool,
    EVLocationTypeCollege,
    EVLocationTypeMilitarySchool,
    EVLocationTypeTechnicalSchool,
    EVLocationTypeShrine,
    EVLocationTypeStadium,
    EVLocationTypeMeteorologicalStation,
    EVLocationTypeTheater,
    EVLocationTypeTomb,
    EVLocationTypeTemple,
    EVLocationTypeTower,
    EVLocationTypeTransitTerminal,
    EVLocationTypeTriangulationStation,
    EVLocationTypeUniversityPrepSchool,
    EVLocationTypeUniversity,
    EVLocationTypeVeterinaryFacility,
    EVLocationTypeWall,
    EVLocationTypeZoo
};

@interface EVLocation : NSObject

// A number representing the location index in the trip. Index numbers usually progress with the
// duration of the trip (so a location with index 11 is visited before a location with index
// 21). An index number is unique for a locations in Locations (unless the same location visited
// multiple times, for example home location at start and end of trip will have the same index)
// but "Alt Locations" may have multiple locations with the same index, indicating alternatives
// for the same part of a trip. Index numbers are not serial, so indexes can be (0,1,11,21,22,
// etc.). Index number "0" is unique and always represents the home location.
@property (nonatomic, assign, readwrite) NSUInteger index;

// The index number of the location in a trip, if known. Default is -1
@property (nonatomic, assign, readwrite) NSInteger next;

// Will be present in cities that have an "all airports" IATA code
// e.g. San Francisco, New York, etc.
@property (nonatomic, strong, readwrite) NSString* allAirportCode;

// If a location is not an airport, this key provides 5 recommended airports
// for this location. Airports are named by their IATA code.
@property (nonatomic, strong, readwrite) NSArray* airports;

// A global identifier for the location. IATA code for airports and Geoname ID for other
// locations. Note: if Geoname ID is not defined for a location, a string representing the
// name of the location will be given in as value instead. The format of this name is
// currently not set and MAY CHANGE. If you plan to use this field, please contact us.
@property (nonatomic, strong, readwrite) NSString* geoId;

// Provides a list of actions requested for this location. Actions can include the
// following values: "Get There" (request any way to be transported there, mostly
// flights but can be train, bus etc.), "Get Accommodation", "Get Car".
@property (nonatomic, strong, readwrite) NSSet* actions;

// There are many general request attributes that apply to the
// entire request and not just some portion of it. Examples:
// "last minute deals" and "Low deposits".
@property (nonatomic, strong, readwrite) EVRequestAttributes* requestAttributes;

@property (nonatomic, assign, readwrite) double latitude;
@property (nonatomic, assign, readwrite) double longitude;

@property (nonatomic, assign, readwrite) EVLocationType type;
@property (nonatomic, strong, readwrite) NSString* name;
@property (nonatomic, strong, readwrite) EVTime* departure;
@property (nonatomic, strong, readwrite) EVTime* arrival;
@property (nonatomic, strong, readwrite) EVTime* stay;
@property (nonatomic, strong, readwrite) NSSet* purpose;
@property (nonatomic, strong, readwrite) NSString* derivedFrom;

// TODO: Attributes
@property (nonatomic, strong, readwrite) EVHotelAttributes* hotelAttributes;
@property (nonatomic, strong, readwrite) EVFlightAttributes* flightAttributes;

@property (nonatomic, strong, readwrite) NSDictionary* keys;

// for example, asking a cruise to Las Vegas will search a cruise to nearest port
@property (nonatomic, strong, readwrite) EVLocation* nearestCustomerLocation;

- (instancetype)initWithResponse:(NSDictionary *)response;

- (NSString*)airportCode;
- (BOOL)isTransit;
- (BOOL)isHotelSearch;
- (BOOL)isDestination;

@end
