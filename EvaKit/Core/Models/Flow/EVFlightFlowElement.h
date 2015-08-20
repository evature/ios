//
//  EVFlightFlowElement.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

@interface EVFlightFlowElement : EVFlowElement

@property (nonatomic, strong, readwrite) NSString* roundTripSayIt;
@property (nonatomic, assign, readwrite) NSInteger actionIndex;

@end
