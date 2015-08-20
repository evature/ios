//
//  EVSearchContext.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContext.h"

@implementation EVSearchContext

+ (instancetype)contextWithType:(EVSearchContextType)contextType {
    EVSearchContext *context = [EVSearchContext new];
    context->_type = contextType;
    return context;
}

+ (instancetype)contextForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(searchContext)]) {
        return [self contextWithType:[delegate searchContext]];
    }
    return [self contextWithType:0xFFFF];
}

@end
