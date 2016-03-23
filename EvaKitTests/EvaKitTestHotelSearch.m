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
    @property NSDate*  checkoutDate;
    @property NSInteger durationMin;
    @property NSInteger durationMax;
    @property EVTravelers* travelers;
    @property EVHotelAttributes *attributes;
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
                                       checkoutDate:(NSDate*)checkoutDate
                                          travelers:(EVTravelers*)travelers
                                         attributes:(EVHotelAttributes*)attributes
                                             sortBy:(EVRequestAttributesSort)sortBy
                                          sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self.waitingForSearch = NO;
    
    self.isComplete = isComplete;
    self.location = location;
    self.arriveDateMin = arriveDateMin;
    self.arriveDateMax =  arriveDateMax;
    self.durationMin = durationMin;
    self.durationMax = durationMax;
    self.checkoutDate = checkoutDate;
    self.travelers = travelers;
    self.attributes = attributes;
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
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[[handler location] airports] objectAtIndex:0], @"MIA");
    XCTAssertEqualObjects([[self formatter] stringFromDate:[handler arriveDateMin]], @"2022-11-03" );
    XCTAssertEqual([handler durationMin], 6 );
    XCTAssertEqualObjects([[self formatter] stringFromDate:[handler checkoutDate]], @"2022-11-09" );
    XCTAssertEqualObjects([[[handler.attributes chains] objectAtIndex:0] name], @"Hilton Hotels");
    XCTAssertEqualObjects([[[handler.attributes chains] objectAtIndex:0] gdsCode], @"HH");

    XCTAssertTrue(handler.attributes.parkingFree);
    XCTAssertEqual(handler.attributes.poolType, EVHotelAttributesPoolTypeAny);

    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}




- (void)testHotelSearch2 {
    
    
    NSString *jsonString = @""
    @"    {"
    @"        \"status\": true,"
    @"        \"confidence\": {"
    @"            \"accumulated\": \"High\","
    @"            \"last_utterance_score\": 0.42583092,"
    @"            \"accumulated_score\": 0.98,"
    @"            \"last_utterance\": \"Medium\""
    @"        },"
    @"        \"ver\": \"v1.0.5285\","
    @"        \"input_text\": \"all inclusive business hotel in Miami with a casino on August 25th for 5 nights with at least 4 stars\","
    @"        \"transaction_key\": \"11e5-eea4-21369161-8afb-22000bcbce58\","
    @"        \"session_id\": \"11e5-eea4-21369dc2-8afb-22000bcbce58\","
    @"        \"rid\": null,"
    @"        \"api_reply\": {"
    @"            \"Hotel Attributes\": {"
    @"                \"Accommodation Type\": \"Hotel\","
    @"                \"Casino\": true,"
    @"                \"Quality\": ["
    @"                            4,"
    @"                            null"
    @"                            ],"
    @"                \"Board\": ["
    @"                          \"All Inclusive\""
    @"                          ],"
    @"                \"Business\": true"
    @"            },"
    @"            \"Flow\": ["
    @"                     {"
    @"                         \"RelatedLocations\": ["
    @"                                              1"
    @"                                              ],"
    @"                         \"Type\": \"Hotel\","
    @"                         \"SayIt\": \"At least 4 stars, all inclusive, business hotel with a casino, in Miami Florida, arriving August 25th for 5 nights\""
    @"                     }"
    @"                     ],"
    @"            \"Locations\": ["
    @"                          {"
    @"                              \"Index\": 0,"
    @"                              \"Derived From\": \"Default\","
    @"                              \"Home\": \"Default\","
    @"                              \"Next\": 10"
    @"                          },"
    @"                          {"
    @"                              \"Index\": 10,"
    @"                              \"Airports\": \"MIA,FLL,PBI,MPB,OPF\","
    @"                              \"Name\": \"Miami, Florida, United States (GID=4164138)\","
    @"                              \"Country\": \"US\","
    @"                              \"Longitude\": -80.19366,"
    @"                              \"Latitude\": 25.77427,"
    @"                              \"Type\": \"City\", "
    @"                              \"Geoid\": 4164138, "
    @"                              \"Arrival\": {"
    @"                                  \"Date\": \"2016-08-25\""
    @"                              }, "
    @"                              \"Actions\": ["
    @"                                          \"Get Accommodation\""
    @"                                          ], "
    @"                              \"Stay\": {"
    @"                                  \"Delta\": \"days=+5\""
    @"                              }"
    @"                          }"
    @"                          ], "
    @"            \"SessionText\": ["
    @"                            \"all inclusive business hotel in Miami with a casino on August 25th for 5 nights with at least 4 stars\""
    @"                            ], "
    @"            \"ProcessedText\": \"all inclusive business hotel in Miami with a casino on August 25th for 5 nights with at least 4 stars\", "
    @"            \"SayIt\": \"at least 4 stars, all inclusive, business hotel with a casino, in Miami Florida, arriving August 25th for 5 nights\""
    @"        }, "
    @"        \"message\": \"Successful Parse\""
    @"}";
    
    HotelSearchHandler* handler = [[HotelSearchHandler alloc] init];
    
    [self simulateJSON:jsonString withHandler:handler];
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[[handler location] airports] objectAtIndex:0], @"MIA");
    XCTAssertEqualObjects([[self formatter] stringFromDate:[handler arriveDateMin]], @"2016-08-25" );
    XCTAssertEqual([handler durationMin], 5 );
    XCTAssertEqualObjects([[self formatter] stringFromDate:[handler checkoutDate]], @"2016-08-30" );
    
    XCTAssertTrue([handler.attributes.amenities containsObject:@(EVHotelAttributesAmentitiesBusiness)]);
    XCTAssertTrue([handler.attributes.amenities containsObject:@(EVHotelAttributesAmentitiesCasino)]);
    XCTAssertTrue(handler.attributes.allInclusive);
    XCTAssertEqual(handler.attributes.minStars, 4);
    XCTAssertEqual(handler.attributes.maxStars, -1);
    
    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );
    
}


@end
