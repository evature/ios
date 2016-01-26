//
//  EVSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSearchDelegate.h"

@interface EVSearchModel : NSObject

@property (nonatomic, assign, readonly) BOOL isComplete;

- (instancetype)initWithComplete:(BOOL)isComplete;

- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate;

@end
