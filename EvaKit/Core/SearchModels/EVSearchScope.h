//
//  EVSearchScope.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/18/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContextBase.h"

#define EVSearchContextTypesAll 0xFFFF

@interface EVSearchScope : EVSearchContextBase

+ (instancetype)scopeWithContextTypes:(EVSearchContextType)types;

@end
