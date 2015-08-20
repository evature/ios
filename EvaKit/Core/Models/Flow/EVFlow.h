//
//  EVFlow.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVFlowElement.h"

@interface EVFlow : NSObject

// List of EVFlowElement objects
@property (nonatomic, strong, readwrite) NSArray* flowElements;

- (instancetype)initWithResponse:(NSArray*)response andLocations:(NSArray*)locations;

@end
