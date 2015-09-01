//
//  EVSearchModel.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"

@interface EVSearchModel ()

@property (nonatomic, assign, readwrite) BOOL isComplete;

@end

@implementation EVSearchModel

- (instancetype)initWithComplete:(BOOL)isComplete {
    self = [super init];
    if (self != nil) {
        self.isComplete = isComplete;
    }
    return self;
}

- (void)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    NSAssert(false, @"Reload in subclasses");
}

@end
