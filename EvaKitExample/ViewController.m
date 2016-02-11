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

- (EVCallbackResult*) navigateTo:(EVCRMPageType)page  withSubPage:(NSString*)subPageId withFilter:(NSDictionary*)filter {
    NSLog(@"Handled CRM Navigate!");
    NSLog(@"navigate to %d,   subpage %@", page, subPageId);
    NSError *error;
    if (filter != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:filter
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"navigate filter %@", jsonStr );
    }
//    EVStyledString *result = [EVStyledString styledStringWithString:@"Navigate!"];
//    return [EVCallbackResult responseWithString:result];
    return [EVCallbackResult resultWithNone];
}

- (EVStyledString*)helloMessage {
    return [EVStyledString styledStringWithString:@"This is a demo app, hello there!"];
    //return nil;
}

- (EVCallbackResult*)phoneCall:(EVCRMPageType)page withId:(NSString*)objId withPhoneType:(EVCRMPhoneType)phoneType {
    NSLog(@"Calling %@  type %d", objId, phoneType);
    return nil;
}

- (EVCallbackResult*) setField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId toValue:(NSDictionary*)value {
    NSLog(@"Data Setting %@ in page %d to value %@", fieldPath, page, [value objectForKey:@"value"]);
    return nil;
}

- (EVCallbackResult*) getField:(NSString*)fieldPath inPage:(EVCRMPageType)page withId:(NSString*)objId {
    NSLog(@"Data getting %@ in page %d  %@", fieldPath, page, objId);

    if ([fieldPath isEqualToString:@"value"]) {
        RXPromise* promise = [[RXPromise alloc] init];
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.5);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:@"The expected value is 10,000,000 $"];
            UIColor* highlightColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.2f alpha:1.0f];
            [text addAttribute:NSForegroundColorAttributeName value:highlightColor range:NSMakeRange(22, 12)];
            EVCallbackResult *result = [EVCallbackResult resultWithDisplayString:[EVStyledString styledStringWithAttributedString:text] andSayString:@"10,000,000 $"];
//            EVCallbackResult *result = [EVCallbackResult resultWithDisplayString:[EVStyledString styledStringWithString:@"The expected value is 10,000,000 $"] andSayString:@"10,000,000 $"];
            [promise fulfillWithValue:result];
        });
        EVCallbackResult *immediate = [EVCallbackResult resultWithString:@"The expected value is..."];
        return [EVCallbackResult resultWithPromise:promise andImmediateResult:immediate];
    }
    
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:@"The value is 60%"];
    UIColor* highlightColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.2f alpha:1.0f];
    [text addAttribute:NSForegroundColorAttributeName value:highlightColor range:NSMakeRange(13, 3)];
    EVCallbackResult *result = [EVCallbackResult resultWithStyledString:[EVStyledString styledStringWithAttributedString:text]];
    return result;
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
    if (page == EVFlightPageTypeBoardingTime) {
        return [EVCallbackResult resultWithString:@"Your Boarding time is 12:56pm"];
    }
    if (page == EVFlightPageTypeArrivalTime) {
        return [EVCallbackResult resultWithDisplayString:[EVStyledString styledStringWithString:@"Your arrival time is 11:24am"] andSayString:@"11:24am"];
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
