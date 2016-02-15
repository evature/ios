//
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVFlightNavigateDelegate.h"
#import "EVFlightAttributes.h"

@interface EVFlightNavigateModel : EVSearchModel

@property (nonatomic, assign, readonly) EVFlightPageType page;


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVFlightPageType)page;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVFlightPageType)page;



@end
