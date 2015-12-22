//
//  EVCruiseSearchDelegate.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchDelegate.h"
#import "EVCRMAttributes.h"

@protocol EVCRMNavigateDelegate <EVSearchDelegate>

- (EVCallbackResponse*)navigateTo:(EVCRMPageType)page  withSubPage:(int)subPageId  ofTeam:(EVCRMFilterType)filter;

@end