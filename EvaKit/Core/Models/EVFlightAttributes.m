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
static NSDictionary *foodKeys = nil;
static NSDictionary *pageKeys = nil;

+ (void)load {
    pageKeys = [@{@"itinerary": @(EVFlightPageTypeItinerary),
                  @"gate": @(EVFlightPageTypeGate),
                  @"departuretime": @(EVFlightPageTypeDepartureTime),
                  @"boardingtime": @(EVFlightPageTypeBoardingTime),
                  @"boardingpass": @(EVFlightPageTypeBoardingPass),
                  @"arrivaltime": @(EVFlightPageTypeArrivalTime),
                  } retain];
    
    seatClassKeys = [@{@"First": @(EVFlightAttributesSeatClassFirst),
                       @"Business": @(EVFlightAttributesSeatClassBusiness),
                       @"Premium": @(EVFlightAttributesSeatClassPremium),
                       @"Economy": @(EVFlightAttributesSeatClassEconomy)
                       } retain];
    seatTypeKeys = [@{@"Window": @(EVFlightAttributesSeatTypeWindow),
                      @"Aisle": @(EVFlightAttributesSeatTypeAisle)
                      } retain];
    foodKeys = [@{@"Unknown": @(EVFlightAttributesFoodTypeUnknown),
                  @"Kosher": @(EVFlightAttributesFoodTypeKosher),
                  @"GlattKosher": @(EVFlightAttributesFoodTypeGlattKosher),
                  @"Muslim": @(EVFlightAttributesFoodTypeMuslim),
                  @"Hindu": @(EVFlightAttributesFoodTypeHindu),
                  @"Vegetarian": @(EVFlightAttributesFoodTypeVegetarian),
                  @"Vegan": @(EVFlightAttributesFoodTypeVegan),
                  @"IndianVegetarian": @(EVFlightAttributesFoodTypeIndianVegetarian),
                  @"RawVegetarian": @(EVFlightAttributesFoodTypeRawVegetarian),
                  @"OrientalVegetarian": @(EVFlightAttributesFoodTypeOrientalVegetarian),
                  @"LactoOvoVegetarian": @(EVFlightAttributesFoodTypeLactoOvoVegetarian),
                  @"LactoVegetarian": @(EVFlightAttributesFoodTypeLactoVegetarian),
                  @"OvoVegetarian": @(EVFlightAttributesFoodTypeOvoVegetarian),
                  @"JainVegetarian": @(EVFlightAttributesFoodTypeJainVegetarian),
                  @"Bland": @(EVFlightAttributesFoodTypeBland),
                  @"Diabetic": @(EVFlightAttributesFoodTypeDiabetic),
                  @"FruitPlatter": @(EVFlightAttributesFoodTypeFruitPlatter),
                  @"GlutenFree": @(EVFlightAttributesFoodTypeGlutenFree),
                  @"LowSodium": @(EVFlightAttributesFoodTypeLowSodium),
                  @"LowCalorie": @(EVFlightAttributesFoodTypeLowCalorie),
                  @"LowFat": @(EVFlightAttributesFoodTypeLowFat),
                  @"LowFibre": @(EVFlightAttributesFoodTypeLowFibre),
                  @"NonCarbohydrate": @(EVFlightAttributesFoodTypeNonCarbohydrate),
                  @"NonLactose": @(EVFlightAttributesFoodTypeNonLactose),
                  @"SoftFluid": @(EVFlightAttributesFoodTypeSoftFluid),
                  @"SemiFluid": @(EVFlightAttributesFoodTypeSemiFluid),
                  @"UlcerDiet": @(EVFlightAttributesFoodTypeUlcerDiet),
                  @"NutFree": @(EVFlightAttributesFoodTypeNutFree),
                  @"LowPurine": @(EVFlightAttributesFoodTypeLowPurine),
                  @"LowProtein": @(EVFlightAttributesFoodTypeLowProtein),
                  @"HighFibre": @(EVFlightAttributesFoodTypeHighFibre),
                  @"Baby": @(EVFlightAttributesFoodTypeBaby),
                  @"PostWeaning": @(EVFlightAttributesFoodTypePostWeaning),
                  @"Child": @(EVFlightAttributesFoodTypeChild),
                  @"Seafood": @(EVFlightAttributesFoodTypeSeafood),
                  @"Japanese": @(EVFlightAttributesFoodTypeJapanese)} retain];
}

+ (EVFlightPageType)stringToPageType:(NSString*)pageName {
    if (pageName) {
        NSNumber* val = [pageKeys objectForKey:[[[pageName lowercaseString]
                                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        if (val != nil) {
            return [val shortValue];
        }
    }
    return EVFlightPageTypeUnknown;
}

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.nonstop = [response objectForKey:@"Nonstop"] != nil ? [[response objectForKey:@"Nonstop"] boolValue] : EVBoolNotSet;
        self.redeye = [response objectForKey:@"Redeye"] != nil ? [[response objectForKey:@"Redeye"] boolValue] : EVBoolNotSet;
        self.only = [response objectForKey:@"Only"] != nil ? [[response objectForKey:@"Only"] boolValue] : EVBoolNotSet;
        self.twoWay = [response objectForKey:@"Two-Way"] != nil ? [[response objectForKey:@"Two-Way"] boolValue] : EVBoolNotSet;
        self.oneWay = [response objectForKey:@"One-Way"] != nil ? [[response objectForKey:@"One-Way"] boolValue] : EVBoolNotSet;
        NSMutableArray* airlines = [NSMutableArray array];
        for (NSDictionary* airline in [response objectForKey:@"Airline"]) {
            [airlines addObject:[airline objectForKey:@"IATA"]];
        }
        self.airlines = [NSArray arrayWithArray:airlines];
        if ([response objectForKey:@"Food"] != nil) {
            NSNumber* val = [foodKeys objectForKey:[[[response objectForKey:@"Food"] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            if (val != nil) {
                self.food = [val shortValue];
            } else {
                self.food = EVFlightAttributesFoodTypeUnknown;
            }
        } else {
            self.food = EVFlightAttributesFoodTypeUnknown;
        }
        
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
                    [classes addObject:val];
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

- (void)dealloc {
    self.seatClass = nil;
    self.airlines = nil;
    [super dealloc];
}

@end
