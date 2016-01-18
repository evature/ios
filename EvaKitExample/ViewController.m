//
//  ViewController.m
//  EvaKitExample
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "ViewController.h"
#import <EvaKit/EvaKit.h>

@implementation ViewController

- (EVCallbackResponse*) navigateTo:(EVCRMPageType)page  withSubPage:(NSString*)subPageId  ofTeam:(EVCRMFilterType)filter {
    NSLog(@"Handled CRM Navigate!");
    NSLog(@"navigate to %d,   subpage %@", page, subPageId);
    NSLog(@"navigate isTeam %d", filter);
//    EVStyledString *result = [EVStyledString styledStringWithString:@"Navigate!"];
//    return [EVCallbackResponse responseWithString:result];
    return [EVCallbackResponse responseWithNone];
}

- (EVCallbackResponse*) setField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId toValue:(NSDictionary*)value {
    NSLog(@"Data Setting %@ in page %d to value %@", fieldPath, page, [value objectForKey:@"value"]);
    return [EVCallbackResponse responseWithNone];
}

- (EVCallbackResponse*) getField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId {
    NSLog(@"Data getting %@ in page %d  %@", fieldPath, page, objId);
    EVStyledString* result =[EVStyledString styledStringWithString:@"The value is 60%"];
    return [EVCallbackResponse responseWithString:result];
}

- (EVCallbackResponse*)handleFlightSearch:(BOOL)isComplete
                             fromLocation:(EVLocation *)origin
                               toLocation:(EVLocation *)destination
                            minDepartDate:(NSDate *)departDateMin
                            maxDepartDate:(NSDate *)departDateMax
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
    NSLog(@"Handled  flight search! Complete: %@", isComplete ? @"YES" : @"NO");
    return [EVCallbackResponse responseWithNone];
}

- (EVCallbackResponse*)navigateTo:(EVFlightPageType)page {
    NSLog(@"Handled  trip navigate to %d", page);
    return [EVCallbackResponse responseWithNone];
}


- (EVCallbackResponse*)handleHotelSearchWhichComplete:(BOOL)isComplete
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
    
    NSLog(@"Handled hotel search! Complete: %@", isComplete ? @"YES" : @"NO");
    return [EVCallbackResponse responseWithNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    EVVoiceChatButton* button = [[EVApplication sharedApplication] addButtonInController:self];
    button.chatToolbarCenterButtonBackgroundShadowRadius = 3.0f;
    button.chatToolbarCenterButtonBackgroundShadowOffset = CGSizeMake(1.0, 1.0);
    //CGSize test = button.chatToolbarCenterButtonBackgroundShadowOffset;
    [button ev_pinToBottomCenteredWithOffset:90.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)evSearchGotResponse:(EVResponse*)response {
    NSLog(@"Some response from eva chat");
}

@end
