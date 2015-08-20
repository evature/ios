//
//  EVResponse.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVResponse.h"

@implementation EVResponse

- (instancetype)initWithResponse:(NSDictionary*)response {
    BOOL status = [[response objectForKey:@"status"] boolValue];
    if (!status) {
        [self release];
        @throw [NSException exceptionWithName:@"BadStatus" reason:@"Response with bad status" userInfo:nil];
    }
    self = [super init];
    if (self != nil) {
        self.sessionId = [response objectForKey:@"session_id"];
        self.transactionId = [response objectForKey:@"transaction_key"];
        
        NSDictionary* apiReply = [response objectForKey:@"api_reply"];
        self.processedText = [apiReply objectForKey:@"ProcessedText"];
        self.originalInputText = [apiReply objectForKey:@"original_input_text"];
        if ([apiReply objectForKey:@"Warnings"] != nil) {
            NSMutableArray* warnings = [NSMutableArray array];
            for (NSArray* warning in [apiReply objectForKey:@"Warnings"]) {
                @try {
                    [warnings addObject:[[[EVWarning alloc] initWithResponse:warning] autorelease]];
                }
                @catch (NSException *exception) {
                    // Some bad formatted warning
                }
            }
            self.warnings = [NSArray arrayWithArray:warnings];
        }
        if ([apiReply objectForKey:@"Last Utterance Parsed Text"] != nil) {
            self.parsedText = [[[EVParsedText alloc] initWithResponse:[apiReply objectForKey:@"Last Utterance Parsed Text"]] autorelease];
        }
        if ([apiReply objectForKey:@"Chat"] != nil) {
            self.chat = [[[EVChat alloc] initWithResponse:[apiReply objectForKey:@"Chat"]] autorelease];
        }
        if ([apiReply objectForKey:@"Dialog"] != nil) {
            self.dialog = [[[EVDialog alloc] initWithResponse:[apiReply objectForKey:@"Dialog"]] autorelease];
        }
        self.sayIt = [apiReply objectForKey:@"SayIt"];
        if ([apiReply objectForKey:@"Locations"] != nil) {
            NSMutableArray* locations = [NSMutableArray array];
            for (NSDictionary* location in [apiReply objectForKey:@"Locations"]) {
                [locations addObject:[[[EVLocation alloc] initWithResponse:location] autorelease]];
            }
            self.locations = [NSArray arrayWithArray:locations];
        }
        if ([apiReply objectForKey:@"Alt Locations"] != nil) {
            NSMutableArray* locations = [NSMutableArray array];
            for (NSDictionary* location in [apiReply objectForKey:@"Alt Locations"]) {
                [locations addObject:[[[EVLocation alloc] initWithResponse:location] autorelease]];
            }
            self.altLocations = [NSArray arrayWithArray:locations];
        }
        self.ean = [apiReply objectForKey:@"ean"];
        if ([apiReply objectForKey:@"sabre"] != nil) {
            self.sabre = [[[EVSabre alloc] initWithResponse:[apiReply objectForKey:@"sabre"]] autorelease];
        }
        self.geoAttributes = [apiReply objectForKey:@"Geo Attributes"];
        if ([apiReply objectForKey:@"Travelers"] != nil) {
            self.travelers = [[[EVTravelers alloc] initWithResponse:[apiReply objectForKey:@"Travelers"]] autorelease];
        }
        if ([apiReply objectForKey:@"Money"] != nil) {
            self.money = [[[EVMoney alloc] initWithResponse:[apiReply objectForKey:@"Money"]] autorelease];
        }
        if ([apiReply objectForKey:@"Flight Attributes"] != nil) {
            self.flightAttributes = [[[EVFlightAttributes alloc] initWithResponse:[apiReply objectForKey:@"Flight Attributes"]] autorelease];
        }
        if ([apiReply objectForKey:@"Hotel Attributes"] != nil) {
            self.hotelAttributes = [[[EVHotelAttributes alloc] initWithResponse:[apiReply objectForKey:@"Hotel Attributes"]] autorelease];
        }
        if ([apiReply objectForKey:@"Service Attributes"] != nil) {
            self.serviceAttributes = [[[EVServiceAttributes alloc] initWithResponse:[apiReply objectForKey:@"Service Attributes"]] autorelease];
        }
        if ([apiReply objectForKey:@"Cruise Attributes"] != nil) {
            self.cruiseAttributes = [[[EVCruiseAttributes alloc] initWithResponse:[apiReply objectForKey:@"Cruise Attributes"]] autorelease];
        }
        if ([apiReply objectForKey:@"Request Attributes"] != nil) {
            NSDictionary* requestAttrs = [apiReply objectForKey:@"Request Attributes"];
            if ([requestAttrs objectForKey:@"PNR"] != nil) {
                self.pnrAttributes = [[[EVPNRAttributes alloc] initWithResponse:[requestAttrs objectForKey:@"PNR"]] autorelease];
            }
            self.requestAttributes = [[[EVRequestAttributes alloc] initWithResponse:requestAttrs] autorelease];
        }
        if ([apiReply objectForKey:@"Flow"] != nil) {
            self.flow = [[[EVFlow alloc] initWithResponse:[apiReply objectForKey:@"Flow"] andLocations:self.locations] autorelease];
        }
        self.sessionText = [apiReply objectForKey:@"SessionText"];
        self.rawResponse = response;
    }
    return self;
}

@end
