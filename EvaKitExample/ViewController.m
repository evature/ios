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

- (void)handleOneWayFlightSearchWhichComplete:(BOOL)isComplete
                                 fromLocation:(EVLocation *)origin
                                   toLocation:(EVLocation *)destination
                                minDepartDate:(NSDate *)departDateMin
                                maxDepartDate:(NSDate *)departDateMax
                                    travelers:(EVTravelers*)travelers
                                      nonStop:(EVBool)nonstop
                                  seatClasses:(NSArray*)seatClasses
                                     airlines:(NSArray*)airlines
                                       redEye:(EVBool)redeye
                                     foodType:(EVFlightAttributesFoodType)food
                                     seatType:(EVFlightAttributesSeatType)seatType
                                       sortBy:(EVRequestAttributesSort)sortBy
                                    sortOrder:(EVRequestAttributesSortOrder)sortOrder {
    NSLog(@"Handled one way flight search! Complete: %@", isComplete ? @"YES" : @"NO");
}


- (void)handleRoundTripFlightSearchWhichComplete:(BOOL)isComplete
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
    NSLog(@"Handled two way flight search! Complete: %@", isComplete ? @"YES" : @"NO");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    EVVoiceChatButton* button = [[EVApplication sharedApplication] addButtonInController:self];
    button.chatToolbarCenterButtonBackgroundShadowRadius = 3.0f;
    button.chatToolbarCenterButtonBackgroundShadowOffset = CGSizeMake(1.0, 1.0);
    CGSize test = button.chatToolbarCenterButtonBackgroundShadowOffset;
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
