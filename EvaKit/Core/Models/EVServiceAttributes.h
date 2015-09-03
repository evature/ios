//
//  EVServiceAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

extern NSString* EVServiceAttributesCallSupport;

@interface EVServiceAttributes : NSObject

@property (nonatomic, assign, readwrite) EVBool callSupportRequested;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
