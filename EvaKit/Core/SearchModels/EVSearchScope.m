//
//  EVSearchScope.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/18/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchScope.h"

@implementation EVSearchScope

+ (instancetype)scopeWithContextTypes:(EVSearchContextType)types {
    EVSearchScope *scope = [[EVSearchScope new] autorelease];
    scope->_type = types;
    return scope;
}

@end
