//
//  EvaKitTestFlightSearch.m
//  EvaKit
//
//  Created by Iftah Haimovitch on 21/01/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EvaBaseTest.h"



@interface HotelSearchHandler : UIViewController<SearchHandler, EVHotelSearchDelegate, EVSearchDelegate>
    @property __block BOOL waitingForSearch;
    @property BOOL isComplete;
    @property EVLocation *location;
    @property NSDate *arriveDateMin;
    @property NSDate*  arriveDateMax;
    @property NSInteger durationMin;
    @property NSInteger durationMax;
    @property EVTravelers* travelers;
    @property NSArray* chain;
    @property EVBool selfCatering;
    @property EVBool bedAndBreakfast;
    @property EVBool halfBoard;
    @property EVBool allInclusive;
    @property EVBool drinksInclusive;
    @property NSInteger minStars;
    @property NSInteger maxStars;
    @property NSSet* amenities;
    @property EVRequestAttributesSort sortBy;
    @property EVRequestAttributesSortOrder sortOrder;
@end

@implementation HotelSearchHandler
- (id) init {
    self = [super init];
    self.waitingForSearch = YES;
    return self;
}

- (EVCallbackResult*)handleHotelSearchWhichComplete:(BOOL)isComplete
                                           location:(EVLocation*)location
                                      arriveDateMin:(NSDate*)arriveDateMin
                                      arriveDateMax:(NSDate*)arriveDateMax
                                        durationMin:(NSInteger)durationMin
                                        durationMax:(NSInteger)durationMax
                                          travelers:(EVTravelers*)travelers
                                        hotelsChain:(NSArray*)chain
                                       selfCatering:(EVBool)selfCatering
                                    bedAndBreakfast:(EVBool)bedAndBreakfast
                                          halfBoard:(EVBool)halfBoard
                                          fullBoard:(EVBool)fullBoard
                                       allInclusive:(EVBool)allInclusive
                                    drinksInclusive:(EVBool)drinksInclusive
                                           minStars:(NSInteger)minStars
                                           maxStars:(NSInteger)maxStars
                                          amenities:(NSSet*)amenities
                                             sortBy:(EVRequestAttributesSort)sortBy
                                          sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self.waitingForSearch = NO;
    
    self.isComplete = isComplete;
    self.location = location;
    self.arriveDateMin = arriveDateMin;
    self.arriveDateMax =  arriveDateMax;
    self.durationMin = durationMin;
    self.durationMax = durationMax;
    self.travelers = travelers;
    self.chain = chain;
    self.selfCatering = selfCatering;
    self.bedAndBreakfast = bedAndBreakfast;
    self.halfBoard = halfBoard;
    self.allInclusive = allInclusive;
    self.drinksInclusive = drinksInclusive;
    self.minStars = minStars;
    self.maxStars = maxStars;
    self.amenities = amenities;
    self.sortBy = sortBy;
    self.sortOrder = sortOrder;
    
    return nil;
}
@end


@interface EvaKitTestHotelSearch : EvaBaseTest

@end

@implementation EvaKitTestHotelSearch



- (void)testHotelSearch {

    
    NSString *jsonString = @""
    "{"
    "    \"status\": true,"
    "    \"confidence\": {"
    "        \"accumulated\": \"High\","
    "        \"last_utterance_score\": 0.5075103,"
    "        \"accumulated_score\": 0.99,"
    "        \"last_utterance\": \"Medium\""
    "    },"
    "    \"ver\": \"v1.0.5232\","
    "    \"input_text\": \"Hilton hotel in Miami from November 3rd 2022 to November 9th 2022 with a pool and free parking\","
    "    \"transaction_key\": \"11e5-d2fb-01c10f97-8aeb-22000b68978c\","
    "    \"session_id\": \"11e5-d2fb-01c11c28-8aeb-22000b68978c\","
    "    \"rid\": null,"
    "    \"api_reply\": {"
    "        \"Hotel Attributes\": {"
    "            \"Pool\": \"Any\","
    "            \"Parking\": {"
    "                \"Facilities\": true,"
    "                \"Free\": true"
    "            }"
    "        },"
    "        \"Flow\": ["
    "                 {"
    "                     \"RelatedLocations\": ["
    "                                          1"
    "                                          ],"
    "                     \"Type\": \"Hotel\","
    "                     \"SayIt\": \"Hilton hotel with a swimming pool and free parking, in Miami Florida, arriving November 3rd, 2022 for 6 nights\""
    "                 }"
    "                 ],"
    "        \"Locations\": ["
    "                      {"
    "                          \"Index\": 0,"
    "                          \"Derived From\": \"Default\","
    "                          \"Home\": \"Default\","
    "                          \"Next\": 10"
    "                      },"
    "                      {"
    "                          \"Index\": 10,"
    "                          \"Airports\": \"MIA,FLL,PBI,MPB,OPF\","
    "                          \"Name\": \"Miami, Florida, United States (GID=4164138)\","
    "                          \"Country\": \"US\","
    "\"Hotel Attributes\": {"
    "    \"Chain\": ["
    "              {"
    "                  \"gds_code\": \"HH\","
    "                  \"Name\": \"Hilton Hotels\","
    "                  \"eva_code\": \"EPC-47\","
    "                  \"simple_name\": \"Hilton\""
    "              }"
    "              ]"
    "},"
    "                          \"Longitude\": -80.19366,"
    "                          \"Latitude\": 25.77427,"
    "                          \"Type\": \"City\","
    "                          \"Geoid\": 4164138, "
    "                          \"Arrival\": {"
    "                              \"Date\": \"2022-11-03\""
    "                          }, "
    "                          \"Actions\": ["
    "                                      \"Get Accommodation\""
    "                                      ], "
    "                          \"Stay\": {"
    "                              \"Delta\": \"days=+6\""
    "                          }"
    "                      }"
    "                      ], "
    "        \"SessionText\": ["
    "                        \"Hilton hotel in Miami from November 3rd 2022 to November 9th 2022 with a pool and free parking\""
    "                        ], "
    "        \"ProcessedText\": \"Hilton hotel in Miami from November 3rd 2022 to November 9th 2022 with a pool and free parking\", "
    "        \"SayIt\": \"Hilton hotel with a swimming pool and free parking, in Miami Florida, arriving November 3rd, 2022 for 6 nights\""
    "    }, "
    "    \"message\": \"Successful Parse\""
    "}";
    HotelSearchHandler* handler = [[HotelSearchHandler alloc] init];
    
    [self simulateJSON:jsonString withHandler:handler];
    /*
    @property EVLocation *location;
    @property NSDate *arriveDateMin;
    @proper ty NSDate*  arriveDateMax;
    @property NSInteger durationMin;
    @property NSInteger durationMax;
    @property EVTravelers* travelers;
    @property NSArray* chain;
    @property EVBool selfCatering;
    @property EVBool bedAndBreakfast;
    @property EVBool halfBoard;
    @property EVBool allInclusive;
    @property EVBool drinksInclusive;
    @property NSInteger minStars;
    @property NSInteger maxStars;
    @property NSSet* amenities;

    */
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[[handler location] airports] objectAtIndex:0], @"MIA");
    XCTAssertEqualObjects([[self formatter] stringFromDate:[handler arriveDateMin]], @"2022-11-03" );
    XCTAssertEqual([handler durationMin], 6 );
    XCTAssertEqualObjects([[[handler chain] objectAtIndex:0] name], @"Hilton Hotels");
    XCTAssertEqualObjects([[[handler chain] objectAtIndex:0] gdsCode], @"HH");
//    XCTAssertTrue([[handler amenities] containsObject:@"Pool"]);


    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}

@end
