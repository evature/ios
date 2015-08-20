//
//  EVFlightAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlightAttributes.h"

@implementation EVFlightAttributes

static NSDictionary* seatClassKeys = nil;
static NSDictionary* seatTypeKeys = nil;

+ (void)load {
    seatClassKeys = [@{@"First": @(EVFlightAttributesSeatClassFirst),
                       @"Business": @(EVFlightAttributesSeatClassBusiness),
                       @"Premium": @(EVFlightAttributesSeatClassPremium),
                       @"Economy": @(EVFlightAttributesSeatClassEconomy)
                       } retain];
    seatTypeKeys = [@{@"Window": @(EVFlightAttributesSeatTypeWindow),
                      @"Aisle": @(EVFlightAttributesSeatTypeAisle)
                      } retain];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.nonstop = [[response objectForKey:@"Nonstop"] boolValue];
        self.redeye = [[response objectForKey:@"Redeye"] boolValue];
        self.only = [[response objectForKey:@"Only"] boolValue];
        self.twoWay = [[response objectForKey:@"Two-Way"] boolValue];
        self.oneWay = [[response objectForKey:@"One-Way"] boolValue];
        NSMutableArray* airlines = [NSMutableArray array];
        for (NSDictionary* airline in [response objectForKey:@"Airline"]) {
            [airlines addObject:[airline objectForKey:@"IATA"]];
        }
        self.airlines = [NSArray arrayWithArray:airlines];
        self.food = [response objectForKey:@"Food"];
        
        if ([response objectForKey:@"Seat"] != nil) {
            NSNumber* val = [seatTypeKeys objectForKey:[response objectForKey:@"Seat"]];
            if (val != nil) {
                self.seatType = [val shortValue];
            } else {
                self.seatType = EVFlightAttributesSeatTypeUnknown;
            }
        } else {
            self.seatType = EVFlightAttributesSeatTypeUnknown;
        }
        
        if ([response objectForKey:@"Seat Class"] != nil) {
            NSMutableArray* classes = [NSMutableArray array];
            for (NSString* seatCls in [response objectForKey:@"Seat Class"]) {
                NSNumber* val = [seatClassKeys objectForKey:seatCls];
                if (val != nil) {
                    [classes addObject:seatCls];
                } else {
                    [classes addObject:@(EVFlightAttributesSeatClassUnknown)];
                }
            }
            self.seatClass = [NSArray arrayWithArray:classes];
        } else {
            self.seatClass = [NSArray array];
        }
        
    }
    return self;
}

@end
