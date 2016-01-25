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
    XCTAssertEqual([handler seatType], EVFlightAttributesSeatTypeUnknown );
    XCTAssertEqualObjects([[handler seatClasses] objectAtIndex:0], @(EVFlightAttributesSeatClassBusiness) );
    
    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}


- (void)testFlightSearchIncomplete {
    NSString *jsonString = @""
    "    {"
    "        \"status\": true,"
    "        \"confidence\": {"
    "            \"accumulated\": \"High\","
    "            \"last_utterance_score\": 0.58021419,"
    "            \"accumulated_score\": 0.99,"
    "            \"last_utterance\": \"High\""
    "        },"
    "        \"ver\": \"v1.0.5192\","
    "        \"input_text\": \"Fly from London to NY\","
    "        \"transaction_key\": \"11e5-c344-dad4b24a-8af2-22000b689d16\","
    "        \"session_id\": \"11e5-c344-dad4bb94-8af2-22000b689d16\","
    "        \"rid\": null,"
    "        \"api_reply\": {"
    "            \"Flow\": ["
    "                     {"
    "                         \"QuestionType\": \"Open\","
    "                         \"Type\": \"Question\","
    "                         \"RelatedLocations\": ["
    "                                              0"
    "                                              ],"
    "                         \"QuestionSubCategory\": \"Departure\","
    "                         \"ActionType\": \"Flight\","
    "                         \"QuestionCategory\": \"Missing Date\","
    "                         \"SayIt\": \"Please specify, When would you like to depart from London United Kingdom to New York City New York?\""
    "                     }"
    "                     ],"
    "            \"SessionText\": ["
    "                            \"Fly from London to NY\""
    "                            ],"
    "            \"ProcessedText\": \"Fly from London to NY\","
    "            \"Locations\": ["
    "                          {"
    "                              \"Index\": 0,"
    "                              \"All Airports Code\": \"LON\","
    "                              \"Airports\": \"LHR,LGW,LCY,STN\","
    "                              \"Name\": \"London, United Kingdom (GID=2643743)\","
    "                              \"Country\": \"GB\","
    "                              \"Longitude\": -0.12574,"
    "                              \"Next\": 12,"
    "                              \"Latitude\": 51.50853,"
    "                              \"Derived From\": \"Text\","
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              }, "
    "                              \"Home\": \"Text\", "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 2643743"
    "                          }, "
    "                          {"
    "                              \"Index\": 12, "
    "                              \"All Airports Code\": \"NYC\", "
    "                              \"Airports\": \"EWR,JFK,LGA,PHL\", "
    "                              \"Name\": \"New York City, New York, United States (GID=5128581)\", "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ], "
    "                              \"Latitude\": 40.71427, "
    "                              \"Country\": \"US\", "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 5128581, "
    "                              \"Longitude\": -74.00597"
    "                          }"
    "                          ], "
    "            \"SayIt\": \"flights from London United Kingdom to New York City New York\""
    "        }, "
    "        \"message\": \"Successful Parse\""
    "    }";
    
    FlightSearchHandler *handler = [[FlightSearchHandler alloc] init];
    
    [self simulateJSON:jsonString withHandler:handler];
    
    
    XCTAssertEqual([handler isComplete], false);
    XCTAssertEqualObjects([[handler origin] allAirportCode], @"LON");
    XCTAssertEqualObjects([[handler destination] allAirportCode] , @"NYC");
}


- (void)testFlightSearchOneWayTravelers {
    NSString *jsonString = @""
    "    {"
    "        \"status\": true,"
    "        \"confidence\": {"
    "            \"accumulated\": \"High\","
    "            \"last_utterance_score\": 0.59528759,"
    "            \"accumulated_score\": 0.99,"
    "            \"last_utterance\": \"High\""
    "        },"
    "        \"ver\": \"v1.0.5192\","
    "        \"input_text\": \"one infant 2 children, 4 adults and 3 elderly fly from new york to london on September 17th 2025 one way\","
    "        \"transaction_key\": \"11e5-c345-8b88e98a-8af2-22000b689d16\","
    "        \"session_id\": \"11e5-c345-8b88f5c2-8af2-22000b689d16\","
    "        \"rid\": null,"
    "        \"api_reply\": {"
    "            \"Flight Attributes\": {"
    "                \"One-Way\": true"
    "            },"
    "            \"Travelers\": {"
    "                \"Infant\": \"1\","
    "                \"Adult\": \"4\","
    "                \"Elderly\": \"3\","
    "                \"Child\": \"2\""
    "            },"
    "            \"Flow\": ["
    "                     {"
    "                         \"SayIt\": \"One way flights from New York City New York to London United Kingdom, departing September 17th, 2025\","
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
    "                              \"All Airports Code\": \"NYC\","
    "                              \"Airports\": \"EWR,JFK,LGA,PHL\","
    "                              \"Name\": \"New York City, New York, United States (GID=5128581)\","
    "                              \"Country\": \"US\","
    "                              \"Departure\": {"
    "                                  \"Date\": \"2025-09-17\""
    "                              },"
    "                              \"Longitude\": -74.00597,"
    "                              \"Next\": 12,"
    "                              \"Latitude\": 40.71427,"
    "                              \"Derived From\": \"Text\","
    "                              \"Request Attributes\": {"
    "                                  \"Transport Type\": ["
    "                                                     \"Airplane\""
    "                                                     ]"
    "                              },"
    "                              \"Home\": \"Text\","
    "                              \"Type\": \"City\","
    "                              \"Geoid\": 5128581"
    "                          },"
    "                          {"
    "                              \"Index\": 12, "
    "                              \"All Airports Code\": \"LON\", "
    "                              \"Airports\": \"LHR,LGW,LCY,STN\", "
    "                              \"Name\": \"London, United Kingdom (GID=2643743)\", "
    "                              \"Country\": \"GB\", "
    "                              \"Longitude\": -0.12574, "
    "                              \"Latitude\": 51.50853, "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 2643743, "
    "                              \"Arrival\": {"
    "                                  \"Date\": \"2025-09-17\", "
    "                                  \"Calculated\": true"
    "                              }, "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ]"
    "                          }"
    "                          ], "
    "            \"SessionText\": ["
    "                            \"one infant 2 children, 4 adults and 3 elderly fly from new york to london on September 17th 2025 one way\""
    "                            ], "
    "            \"ProcessedText\": \"one infant 2 children 4 adults and 3 elderly fly from new york to london on September 17th 2025 one way\", "
    "            \"SayIt\": \"one way flights from New York City New York to London United Kingdom, departing September 17th, 2025, for 4 adults, 2 children, 1 infant and 3 elderlies\""
    "        }, "
    "        \"message\": \"Successful Parse\""
    "    }";
    
    FlightSearchHandler *handler = [[FlightSearchHandler alloc] init];
    [self simulateJSON:jsonString withHandler:handler];
    
    
    XCTAssertEqual([handler isComplete], true);
    XCTAssertEqualObjects([[handler origin] allAirportCode], @"NYC");
    XCTAssertEqualObjects([[handler destination] allAirportCode] , @"LON");
    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMin]], @"2025-09-17" );
    //    XCTAssertEqualObjects([formatter stringFromDate:[handler departDateMax]], @"2025-12-13" );

    XCTAssertEqualObjects([handler returnDateMin], nil );
    //    XCTAssertEqualObjects([formatter stringFromDate:[handler returnDateMax]], @"2025-12-16" );
    
    XCTAssertEqual([[handler travelers] adult], 4 );
    XCTAssertEqual([[handler travelers] elderly], 3 );
    XCTAssertEqual([[handler travelers] infant], 1 );
    XCTAssertEqual([[handler travelers] child], 2 );
    XCTAssertEqual([[handler travelers] getAllAdults], 7 );
    XCTAssertEqual([[handler travelers] getAllChildren], 3 );
    
    XCTAssertFalse(EV_IS_BOOL_SET([handler nonstop]) );
    
    XCTAssertEqualObjects([handler airlines], @[] );
    XCTAssertEqualObjects([handler seatClasses], @[] );
    XCTAssertEqual([handler food], EVFlightAttributesFoodTypeUnknown );
    XCTAssertEqual([handler seatType], EVFlightAttributesSeatTypeUnknown );
    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );

}



- (void)testFlightSearchIncompleteNonStopAisle {
    NSString *jsonString = @""
    "    {"
    "        \"status\": true,"
    "        \"confidence\": {"
    "            \"accumulated\": \"High\","
    "            \"last_utterance_score\": 0.5620678,"
    "            \"accumulated_score\": 0.99,"
    "            \"last_utterance\": \"High\""
    "        },"
    "        \"ver\": \"v1.0.5192\","
    "        \"input_text\": \"non stop flight from NY to Kiev, with aisle seat\","
    "        \"transaction_key\": \"11e5-c348-25affbb5-8ada-22000b468da6\","
    "        \"session_id\": \"11e5-c348-25b00761-8ada-22000b468da6\","
    "        \"rid\": null,"
    "        \"api_reply\": {"
    "            \"Flight Attributes\": {"
    "                \"Nonstop\": true,"
    "                \"Seat\": \"Aisle\""
    "            },"
    "            \"Flow\": ["
    "                     {"
    "                         \"QuestionType\": \"Open\","
    "                         \"Type\": \"Question\","
    "                         \"RelatedLocations\": ["
    "                                              0"
    "                                              ],"
    "                         \"QuestionSubCategory\": \"Departure\","
    "                         \"ActionType\": \"Flight\","
    "                         \"QuestionCategory\": \"Missing Date\","
    "                         \"SayIt\": \"Please specify, When would you like to depart from New York City New York to Kiev Ukraine?\""
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
    "                              \"Longitude\": -74.00597,"
    "                              \"Next\": 12,"
    "                              \"Derived From\": \"Text\","
    "                              \"Latitude\": 40.71427,"
    "                              \"Home\": \"Text\","
    "                              \"Flight Attributes\": {"
    "                                  \"Nonstop\": true"
    "                              }, "
    "                              \"Geoid\": 5128581"
    "                          }, "
    "                          {"
    "                              \"Index\": 12, "
    "                              \"Airports\": \"KBP,IEV,QOH,QOF,CEJ\", "
    "                              \"Name\": \"Kiev, Ukraine (GID=703448)\", "
    "                              \"Actions\": ["
    "                                          \"Get There\""
    "                                          ], "
    "                              \"Latitude\": 50.45466, "
    "                              \"Country\": \"UA\", "
    "                              \"Type\": \"City\", "
    "                              \"Geoid\": 703448, "
    "                              \"Longitude\": 30.5238"
    "                          }"
    "                          ], "
    "            \"SessionText\": ["
    "                            \"non stop flight from NY to Kiev, with aisle seat\""
    "                            ], "
    "            \"ProcessedText\": \"non stop flight from NY to Kiev with aisle seat\", "
    "            \"SayIt\": \"nonstop flights from New York City New York to Kiev Ukraine\""
    "        }, "
    "        \"message\": \"Successful Parse\""
    "    }";
    FlightSearchHandler *handler = [[FlightSearchHandler alloc] init];
    [self simulateJSON:jsonString withHandler:handler];
    
    
    XCTAssertEqual([handler isComplete], false);
    XCTAssertEqualObjects([[handler origin] allAirportCode], @"NYC");
    XCTAssertEqualObjects([[[handler destination] airports] objectAtIndex:0], @"KBP");
    XCTAssertEqual([[[handler destination] airports] count], 5);
    XCTAssertEqualObjects([handler departDateMin], nil );
    XCTAssertEqualObjects([handler returnDateMin], nil );
    
    XCTAssert(EV_IS_TRUE([handler nonstop]) );
    
    XCTAssertEqualObjects([handler airlines], @[] );
    XCTAssertEqualObjects([handler seatClasses], @[] );
    XCTAssertEqual([handler food], EVFlightAttributesFoodTypeUnknown );
    XCTAssertEqual([handler seatType], EVFlightAttributesSeatTypeAisle );
    XCTAssertEqual([handler sortBy], EVRequestAttributesSortUnknown );
    XCTAssertEqual([handler sortOrder], EVRequestAttributesSortOrderUnknown );
}

@end
