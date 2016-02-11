//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMNavigateDelegate <EVSearchDelegate>

- (EVCallbackResult*)navigateTo:(EVCRMPageType)page  withSubPage:(NSString*)subPageId  withFilter:(NSDictionary*)filter;

@end