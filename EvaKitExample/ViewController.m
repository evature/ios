//
//  ViewController.m
//  EvaKitExample
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "ViewController.h"
#import <EvaKit/EvaKit.h>
#import "TableViewController.h"

@implementation ViewController

- (EVCallbackResult*) navigateTo:(EVCRMPageType)page  withSubPage:(NSString*)subPageId  ofTeam:(EVCRMFilterType)filter {
    NSLog(@"Handled CRM Navigate!");
    NSLog(@"navigate to %d,   subpage %@", page, subPageId);
    NSLog(@"navigate isTeam %d", filter);
//    EVStyledString *result = [EVStyledString styledStringWithString:@"Navigate!"];
//    return [EVCallbackResult responseWithString:result];
    return [EVCallbackResult resultWithNone];
}

- (EVStyledString*)helloMessage {
    return [EVStyledString styledStringWithString:@"This is a demo app, hello there!"];
    //return nil;
}

- (EVCallbackResult*) setField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId toValue:(NSDictionary*)value {
    NSLog(@"Data Setting %@ in page %d to value %@", fieldPath, page, [value objectForKey:@"value"]);
    return [EVCallbackResult resultWithNone];
}

- (EVCallbackResult*) getField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId {
    NSLog(@"Data getting %@ in page %d  %@", fieldPath, page, objId);
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] initWithString:@"The value is 60%"];
    UIColor* highlightColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.2f alpha:1.0f];
    [result addAttribute:NSForegroundColorAttributeName value:highlightColor range:NSMakeRange(13, 3)];
    return [EVCallbackResult resultWithString:[EVStyledString styledStringWithAttributedString:result]];
}

- (EVCallbackResult*)handleFlightSearch:(BOOL)isComplete
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
    return [EVCallbackResult resultWithNone];
}

- (EVCallbackResult*)navigateTo:(EVFlightPageType)page {
    NSLog(@"Handled  trip navigate to %d", page);
    if (page == EVFlightPageTypeItinerary) {
        UIViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigatedToScene"];

        [[self navigationController] setViewControllers:[NSArray arrayWithObject: secondViewController]
                                               animated: YES];
        [[EVApplication sharedApplication] hideChatViewController:self];
    }
    if (page == EVFlightPageTypeBoardingTime) {
        EVStyledString *styledString = [EVStyledString styledStringWithString:@"Your Boarding time is 12:56pm"];
        return [EVCallbackResult resultWithString:styledString];
    }
    if (page == EVFlightPageTypeArrivalTime) {
        EVCallbackResultData *data = [[EVCallbackResultData alloc]init];
        data.sayIt = @"11:24am";
        data.displayIt = [EVStyledString styledStringWithString:@"Your arrival time is 11:24am"];
        return [EVCallbackResult resultWithResultData:data];
    }
    return [EVCallbackResult resultWithNone];
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
    
    NSLog(@"Handled hotel search! Complete: %@", isComplete ? @"YES" : @"NO");
    return [EVCallbackResult resultWithNone];
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
