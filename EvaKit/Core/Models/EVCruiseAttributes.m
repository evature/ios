//
//  EVCruiseAttributes.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCruiseAttributes.h"

@implementation EVCruiseline

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.name = [response objectForKey:@"Name"];
        if ([response objectForKey:@"Keys"] != nil) {
            NSDictionary* keysDict = [response objectForKey:@"Keys"];
            NSString* key = [[keysDict allKeys] lastObject];
            if (key != nil) {
                self.key = [keysDict objectForKey:key];
            }
        }
    }
    return self;
}


@end

@implementation EVCruiseship

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.name = [response objectForKey:@"Name"];
        if ([response objectForKey:@"Keys"] != nil) {
            NSDictionary* keysDict = [response objectForKey:@"Keys"];
            NSString* key = [[keysDict allKeys] lastObject];
            if (key != nil) {
                self.key = [keysDict objectForKey:key];
            }
        }
    }
    return self;
}

@end

@implementation EVCruiseAttributes

static NSDictionary* cabinKeys = nil;
static NSDictionary* poolKeys = nil;
static NSDictionary* boardKeys = nil;
static NSDictionary* sizeKeys = nil;

+ (void)load {
    cabinKeys = [@{@"Other": @(EVCruiseAttributesCabinTypeOther),
                   @"Windowless": @(EVCruiseAttributesCabinTypeWindowless),
                   @"RegularCabin": @(EVCruiseAttributesCabinTypeRegularCabin),
                   @"Balcony": @(EVCruiseAttributesCabinTypeBalcony),
                   @"PortHole": @(EVCruiseAttributesCabinTypePortHole),
                   @"Picture": @(EVCruiseAttributesCabinTypePicture),
                   @"FullWall": @(EVCruiseAttributesCabinTypeFullWall),
                   @"Internal": @(EVCruiseAttributesCabinTypeInternal),
                   @"Oceanview": @(EVCruiseAttributesCabinTypeOceanview),
                   @"Window": @(EVCruiseAttributesCabinTypeWindow),
                   @"External": @(EVCruiseAttributesCabinTypeExternal),
                   @"Suite": @(EVCruiseAttributesCabinTypeSuite),
                   @"Cabin": @(EVCruiseAttributesCabinTypeCabin),
                   @"MiniSuite": @(EVCruiseAttributesCabinTypeMiniSuite),
                   @"FamilySuite": @(EVCruiseAttributesCabinTypeFamilySuite),
                   @"PresidentialSuite": @(EVCruiseAttributesCabinTypePresidentialSuite)
                   } retain];
    poolKeys = [@{@"Other": @(EVCruiseAttributesPoolTypeOther),
                  @"Any": @(EVCruiseAttributesPoolTypeAny),
                  @"Indoor": @(EVCruiseAttributesPoolTypeIndoor),
                  @"Outdoor": @(EVCruiseAttributesPoolTypeOutdoor),
                  @"Children": @(EVCruiseAttributesPoolTypeChildren)
                  } retain];
    boardKeys = [@{@"Other": @(EVCruiseAttributesBoardTypeOther),
                   @"FullBoard": @(EVCruiseAttributesBoardTypeFullBoard),
                   @"AllInclusive": @(EVCruiseAttributesBoardTypeAllInclusive)
                   } retain];
    sizeKeys = [@{@"Other": @(EVCruiseAttributesShipSizeOther),
                  @"Small": @(EVCruiseAttributesShipSizeSmall),
                  @"Medium": @(EVCruiseAttributesShipSizeMedium),
                  @"Large": @(EVCruiseAttributesShipSizeLarge),
                  } retain];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Cruiseline"] != nil) {
            NSMutableArray* lines = [NSMutableArray array];
            for (NSDictionary* line in [response objectForKey:@"Cruiseline"]) {
                [lines addObject:[[[EVCruiseline alloc] initWithResponse:line] autorelease]];
            }
            self.cruiselines = [NSArray arrayWithArray:lines];
        }
        if ([response objectForKey:@"Cruiseship"] != nil) {
            NSMutableArray* lines = [NSMutableArray array];
            for (NSDictionary* line in [response objectForKey:@"Cruiseship"]) {
                [lines addObject:[[[EVCruiseship alloc] initWithResponse:line] autorelease]];
            }
            self.cruiseships = [NSArray arrayWithArray:lines];
        }
        self.family = [[response objectForKey:@"Family"] boolValue];
        self.romantic = [[response objectForKey:@"Romantic"] boolValue];
        self.adventure = [[response objectForKey:@"Adventure"] boolValue];
        self.childFree = [[response objectForKey:@"Child Free"] boolValue];
        self.yacht = [[response objectForKey:@"Yacht"] boolValue];
        self.barge = [[response objectForKey:@"Barge"] boolValue];
        self.sailingShip = [[response objectForKey:@"Sailing Ship"] boolValue];
        self.riverCruise = [[response objectForKey:@"River Cruise"] boolValue];
        self.forSingles = [[response objectForKey:@"For Singles"] boolValue];
        self.forGays = [[response objectForKey:@"For Gays"] boolValue];
        self.steamboat = [[response objectForKey:@"Steamboat"] boolValue];
        self.petFriendly = [[response objectForKey:@"Pet Friendly"] boolValue];
        self.yoga = [[response objectForKey:@"Yoga"] boolValue];
        self.landTour = [[response objectForKey:@"Land Tour"] boolValue];
        self.oneWay = [[response objectForKey:@"One Way"] boolValue];
        
        if ([response objectForKey:@"Quality"] != nil) {
            NSArray* quality = [response objectForKey:@"Quality"];
            self.minStars = [[quality objectAtIndex:0] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:0] integerValue];
            self.maxStars = [[quality objectAtIndex:1] isEqual:[NSNull null]] ? -1 : [[quality objectAtIndex:1] integerValue];
        }
        if ([response objectForKey:@"Pool"] != nil) {
            NSNumber* val = [poolKeys objectForKey:[[response objectForKey:@"Pool"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            if (val != nil) {
                self.pool = [val shortValue];
            } else {
                self.pool = EVCruiseAttributesPoolTypeOther;
            }
        } else {
            self.pool = EVCruiseAttributesPoolTypeOther;
        }
        if ([response objectForKey:@"Cabin"] != nil) {
            NSNumber* val = [cabinKeys objectForKey:[[[response objectForKey:@"Cabin"] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            if (val != nil) {
                self.cabin = [val shortValue];
            } else {
                self.cabin = EVCruiseAttributesCabinTypeOther;
            }
        } else {
            self.cabin = EVCruiseAttributesCabinTypeOther;
        }
        if ([response objectForKey:@"Board"] != nil) {
            NSNumber* val = [boardKeys objectForKey:[[response objectForKey:@"Board"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            if (val != nil) {
                self.board = [val shortValue];
            } else {
                self.board = EVCruiseAttributesBoardTypeOther;
            }
        } else {
            self.board = EVCruiseAttributesBoardTypeOther;
        }
        if ([response objectForKey:@"Ship Size"] != nil) {
            NSNumber* val = [sizeKeys objectForKey:[[response objectForKey:@"Ship Size"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            if (val != nil) {
                self.shipSize = [val shortValue];
            } else {
                self.shipSize = EVCruiseAttributesShipSizeOther;
            }
        } else {
            self.shipSize = EVCruiseAttributesShipSizeOther;
        }
    }
    return self;
}


@end
