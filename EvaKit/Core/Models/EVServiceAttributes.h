//
//  EVServiceAttributes.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVServiceAttributes : NSObject

@property (nonatomic, assign, readwrite) BOOL callSupportRequested;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
