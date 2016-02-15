//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

// In App Navigation - change the current page the user is looking at
@protocol EVCRMNavigateDelegate <EVSearchDelegate>


// Navigate to one of:
//     1. Page (eg. all of contacts)
//     2. a specific sub-page (eg. specific contact)
//     3. a filtered list (eg. today's meetings, my team's opportunities)
//     4. a filtered specific sub-page  (eg. last meeting)
//
// The filter argument currently can contain keys with boolean values,
// the keys are:  today, last, team, my
//
//  eg.
//    for input  "show my opportunities"  you get
//      page = Opportunities
//      filter = { "my": true}
//    for "show me todays meetings" you get
//      page = Appointments
//      filter = { "today": true}
//    for "show me my last meeting" you get
//      page = Appointments
//      filter = { "my": true,  "last": true }
- (EVCallbackResult*)navigateTo:(EVCRMPageType)page  withSubPage:(NSString*)subPageId  withFilter:(NSDictionary*)filter;

@end