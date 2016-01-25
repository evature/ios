//
//  EvaKitTestFlightSearch.m
//  EvaKit
//
//  Created by Iftah Haimovitch on 21/01/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EvaKit.h"
#import "EVAPIRequest.h"


@interface EVApplication (Testing)
// expose the private method:
- (void)apiRequest:(EVAPIRequest*)request gotResponse:(NSDictionary*)response;
@end

@interface FlightSearchHandler : UIViewController<EVFlightSearchDelegate, EVSearchDelegate>
    @property __block BOOL waitingForSearch;
    @property BOOL isComplete;
    @property EVLocation *origin;
    @property EVLocation * destination;
    @property NSDate *departDateMin;
    @property NSDate*  departDateMax;
    @property NSDate* returnDateMin;
    @property NSDate* returnDateMax;
    @property EVTravelers* travelers;
    @property EVBool nonstop;
    @property NSArray* seatClasses;
    @property NSArray* airlines;
    @property EVBool redeye;
    @property EVFlightAttributesFoodType food;
    @property EVFlightAttributesSeatType seatType;
    @property EVRequestAttributesSort sortBy;
    @property EVRequestAttributesSortOrder sortOrder;
@end

@implementation FlightSearchHandler
- (id) init {
    self = [super init];
    self.waitingForSearch = YES;
    return self;
}

- (EVCallbackResponse*)handleFlightSearch:(BOOL)isComplete
                             fromLocation:(EVLocation *)origin
                               toLocation:(EVLocation *) destination
                            minDepartDate:(NSDate *)departDateMin
                            maxDepartDate:(NSDate*) departDateMax
                            minReturnDate:(NSDate*)returnDateMin
                            maxReturnDate:(NSDate*)returnDateMax
                                travelers:(EVTravelers*)travelers
                                  nonStop:(EVBool)nonstop
                              seatClasses:(NSArray*)seatClasses
                                 airlines:(NSArray*)airlines
                                   redEye:(EVBool)redeye
                                 foodType:(EVFlightAttributesFoodType)food
                                 seatType:(EVFlightAttributesSeatType)seatType
                                   sortBy:(EVRequestAttributesSort)sortBy
                                sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    self.waitingForSearch = NO;
    
    self.isComplete = isComplete;
    self.origin = origin;
    self.destination = destination;
    self.departDateMin = departDateMin;
    self.departDateMax = departDateMax;
    self.returnDateMin = returnDateMin;
    self.returnDateMax = returnDateMax;
    self.travelers = travelers;
    self.nonstop = nonstop;
    self.seatClasses = seatClasses;
    self.airlines = airlines;
    self.redeye = redeye;
    self.food = food;
    self.seatType = seatType;
    self.sortBy = sortBy;
    self.sortOrder = sortOrder;
    
    return nil;
}
@end


@interface EvaKitTestFlightSearch : XCTestCase

@end

@implementation EvaKitTestFlightSearch

NSDateFormatter *formatter;


- (void)setUp {
    [super setUp];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
}

- (void)tearDown {
    formatter = nil;
    [super tearDown];
}

- (void) simulateJSON: (NSString*)jsonString withHandler:(FlightSearchHandler*)handler {
    EVApplication *app = [EVApplication sharedApplication];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [app showChatViewController:(UIResponder*)handler];
    [app apiRequest:nil gotResponse:response];
    // Run the loop
    while([handler waitingForSearch]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}



- (void)testFlightSearch {

    
    NSString *jsonString = @""
    "    {"
    "        \"status\": true,"
    "        \"confidence\": {"
    "            \"accumulated\": \"High\","
    "            \"last_utterance_score\": 0.59861303,"
    "            \"accumulated_score\": 0.99,"
    "            \"last_utterance\": \"High\""
    "        },"
    "        \"ver\": \"v1.0.5192\","
    "        \"input_text\": \"Fly from NY to LA on December 13th 2025 return on December 16th 2025 with United sorted by price\","
    "        \"transaction_key\": \"11e5-c053-f6800a19-8aec-22000bd9069b\","
    "        \"rid\": null,"
    "        \"api_reply\": {"
    "            \"Flight Attributes\": {"
    "                \"Two-Way\": true,"
    "                \"Airline\": ["
    "                            {"
    "                                \"IATA\": \"UA\","
    "                                \"Name\": \"United\""
    "                            }"
    "                            ]"
    "            },"
    "            \"Flow\": ["
    "                     {"
    "                         \"SayIt\": \"Flights from New York City New York to Los Angeles California, departing December 13th, 2025, with United sorted by price\","
    "                         \"Type\": \"Flight\","
    "                         \"ReturnTrip\": {"
    "                             \"ActionIndex\": 1,"
    "                             \"SayIt\": \"Return flights from New York City New York to Los Angeles California, departing December 13th, 2025, arriving back December 16th, 2025, with United sorted by price\""
    "                         },"
    "                         \"RelatedLocations\": ["
    "                                              0,"
    "                                              1"
    "                                              ]"
    "                     },"
    "                     {"
    "                         \"SayIt\": \"Flights from Los Angeles California to New York City New York, arriving December 16th, 2025, with United sorted by price\","
    "                         \"Type\": \"Flight\","
    "                         \"RelatedLocations\": ["
    "                                              1,"
    "                                              2"
    "                                              ]"
    "                     }"
    "                     ],"
    "            \"Locations\": ["
    "                          {"
    "                              \"Index\": 0,"
    "                              \"Type\": \"City\","
    "                              \"All Airports Code\": \"NYC\","
    "                              \"Airports\": \"EWR,JFK,LGA,PHL\","
    "                              \"Name\": \"New York City, New York, United States (GID=5128581)\","
    "                              \"Country\": \"US\","
    "                              \"Departure\": {"
    "                                  \"Date\": \"2025-12-13\""
    "                              },"
    "                              \"Longitude\": -74.00597,"
    "                              \"Next\": 12,"
    "                              \"Latitude\": 40.71427,"
    "                              \"Purpose\": ["
    "                                          \"Home\""
    "                                          ],"
    "                              \"Derived From\": \"Text\","
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              },"
    "                              \"Home\": \"Text\","
    "                              \"Flight Attributes\": {"
    "                                  \"Airline\": ["
    "                                              {"
    "                                                  \"IATA\": \"UA\","
    "                                                  \"Name\": \"United\""
    "                                              }"
    "                                              ]"
    "                              },"
    "                              \"Geoid\": 5128581"
    "                          },"
    "                          {"
    "                              \"Arrival\": {"
    "                                  \"Date\": \"2025-12-13\","
    "                                  \"Calculated\": true"
    "                              },"
    "                              \"Index\": 12,"
    "                              \"Type\": \"City\","
    "                              \"Airports\": \"LAX,SNA,LGB,ONT,SAN\","
    "                              \"Name\": \"Los Angeles, California, United States (GID=5368361)\","
    "                              \"Country\": \"US\", "
    "                              \"Departure\": {"
    "                                  \"Date\": \"2025-12-16\", "
    "                                  \"Calculated\": true"
    "                              }, "
    "                              \"Longitude\": -118.24368, "
    "                              \"Next\": 0, "
    "                              \"Latitude\": 34.05223, "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ], "
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              }, "
    "                              \"Flight Attributes\": {"
    "                                  \"Airline\": ["
    "                                              {"
    "                                                  \"IATA\": \"UA\", "
    "                                                  \"Name\": \"United\""
    "                                              }"
    "                                              ]"
    "                              }, "
    "                              \"Geoid\": 5368361"
    "                          }, "
    "                          {"
    "                              \"Arrival\": {"
    "                                  \"Date\": \"2025-12-16\""
    "                              }, "
    "                              \"Index\": 0, "
    "                              \"All Airports Code\": \"NYC\", "
    "                              \"Airports\": \"EWR,JFK,LGA,PHL\", "
    "                              \"Name\": \"New York City, New York, United States (GID=5128581)\", "
    "                              \"Country\": \"US\", "
    "                              \"Longitude\": -74.00597, "
    "                              \"Latitude\": 40.71427, "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ], "
    "                              \"Derived From\": \"Text\", "
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              }, "
    "                              \"Home\": \"Text\", "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 5128581, "
    "                              \"Purpose\": ["
    "                                          \"Home\""
    "                                          ]"
    "                          }"
    "                          ], "
    "            \"Request Attributes\": {"
    "                \"Sort\": {"
    "                    \"Requested\": true, "
    "                    \"By\": \"price\""
    "                }"
    "            }, "
    "            \"ProcessedText\": \"Fly from NY to LA on December 13th 2025 return on December 16th 2025 with United sorted by price\", "
    "            \"SayIt\": \"return flights from New York City New York to Los Angeles California, departing December 13th, 2025, arriving back December 16th, 2025, with United sorted by price\""
    "        }, "
    "        \"message\": \"Successful Parse\""
    "}";
    FlightSearchHandler *handler = [[FlightSearchHandler alloc] init];
    
    [self simulateJSON:jsonString withHandler:handler];
    
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[handler origin] allAirportCode], @"NYC");
    XCTAssertEqualObjects([[[handler destination] airports] objectAtIndex:0], @"LAX");
    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMin]], @"2025-12-13" );
//    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMax]], @"2025-12-13" );
    XCTAssertEqualObjects([formatter stringFromDate:[handler returnDateMin]], @"2025-12-16" );
//    XCTAssertEqualObjects([formatter stringFromDate:[handler returnDateMax]], @"2025-12-16" );

    XCTAssertEqualObjects([handler travelers], nil );
    XCTAssertFalse(EV_IS_BOOL_SET([handler nonstop]) );

    XCTAssertEqualObjects([[handler airlines] objectAtIndex:0], @"UA" );
    XCTAssertFalse(EV_IS_BOOL_SET([handler redeye]) );

    XCTAssertEqual([handler food], EVFlightAttributesFoodTypeUnknown );
    XCTAssertEqual([handler seatType], EVFlightAttributesSeatClassUnknown );

    XCTAssertEqual([handler sortBy], EVRequestAttributesSortPrice );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}


- (void)testFlightSearch2 {
    NSString *jsonString = @""
    "{"
    "        \"status\": true,"
    "        \"confidence\": {"
    "            \"accumulated\": \"High\","
    "            \"last_utterance_score\": 0.59648098,"
    "            \"accumulated_score\": 0.99,"
    "            \"last_utterance\": \"High\""
    "        },"
    "        \"ver\": \"v1.0.5192\","
    "        \"input_text\": \"2 adults fly business class from Rome to JFK in July 15th 2025\","
    "        \"transaction_key\": \"11e5-c338-f8388e11-8af3-22000b689d16\","
    "        \"rid\": null,"
    "        \"api_reply\": {"
    "            \"Flight Attributes\": {"
    "                \"Seat Class\": ["
    "                               \"Business\""
    "                               ]"
    "            },"
    "            \"Travelers\": {"
    "                \"Adult\": \"2\""
    "            },"
    "            \"Flow\": ["
    "                     {"
    "                         \"SayIt\": \"Flights from Rome Italy to John F Kennedy International Airport New York, departing July 15th, 2025, in business class\","
    "                         \"Type\": \"Flight\","
    "                         \"RelatedLocations\": ["
    "                                              0,"
    "                                              1"
    "                                              ]"
    "                     }"
    "                     ],"
    "            \"Locations\": ["
    "                          {"
    "                              \"Index\": 0,"
    "                              \"All Airports Code\": \"ROM\","
    "                              \"Airports\": \"FCO,CIA,PEG,XVY\","
    "                              \"Name\": \"Rome, Italy (GID=3169070)\","
    "                              \"Country\": \"IT\","
    "                              \"Departure\": {"
    "                                  \"Date\": \"2025-07-15\""
    "                              },"
    "                              \"Longitude\": 12.51133,"
    "                              \"Next\": 12,"
    "                              \"Latitude\": 41.89193,"
    "                              \"Derived From\": \"Text\","
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              }, "
    "                              \"Home\": \"Text\", "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 3169070"
    "                          }, "
    "                          {"
    "                              \"Arrival\": {"
    "                                  \"Date\": \"2025-07-15\", "
    "                                  \"Calculated\": true"
    "                              }, "
    "                              \"Index\": 12, "
    "                              \"Airports\": \"JFK\", "
    "                              \"Name\": \"'JFK' = John F Kennedy Intl, US\", "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ], "
    "                              \"Latitude\": 40.633333, "
    "                              \"Country\": \"US\", "
    "                              \"Type\": \"Airport\", "
    "                              \"Geoid\": \"JFK\", "
    "                              \"Longitude\": -73.783333"
    "                          }"
    "                          ], "
    "            \"ProcessedText\": \"2 adults fly business class from Rome to JFK in July 15th 2025\", "
    "            \"SayIt\": \"flights from Rome Italy to John F Kennedy International Airport New York, departing July 15th, 2025, in business class, for 2 adults\""
    "        }, "
    "        \"message\": \"Successful Parse\""
    "    }"
    ;

    FlightSearchHandler *handler = [[FlightSearchHandler alloc] init];
    
    [self simulateJSON:jsonString withHandler:handler];
    
    
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[handler origin] allAirportCode], @"ROM");
    XCTAssertEqualObjects([[[handler destination] airports] objectAtIndex:0], @"JFK");
    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMin]], @"2025-07-15" );
    //    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMax]], @"2025-12-13" );
    XCTAssertEqualObjects([handler returnDateMin], nil );
    //    XCTAssertEqualObjects([formatter stringFromDate:[handler returnDateMax]], @"2025-12-16" );
    
    XCTAssertEqual([[handler travelers] adult], 2 );
    XCTAssertFalse(EV_IS_BOOL_SET([handler nonstop]) );
    
    XCTAssertEqualObjects([handler airlines], @[] );
    XCTAssertFalse(EV_IS_BOOL_SET([handler redeye]) );
    
    XCTAssertEqual([handler food], EVFlightAttributesFoodTypeUnknown );
    XCTAssertEqual([handler seatType], EVFlightAttributesSeatClassUnknown );
    
    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}


@end
