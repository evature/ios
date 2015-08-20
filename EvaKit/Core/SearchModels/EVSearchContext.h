//
//  EVSearchContext.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContextBase.h"
#import "EVSearchDelegate.h"

@interface EVSearchContext : EVSearchContextBase

+ (instancetype)contextWithType:(EVSearchContextType)contextType;

+ (instancetype)contextForDelegate:(id<EVSearchDelegate>)delegate;

@end
