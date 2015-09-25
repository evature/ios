//
//  NSValue+EVConstructors.h
//  EvaKit
//
//  Created by Yegor Popovych on 9/25/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (EVConstructors)

+ (id)ev_valueWithValue:(const void*)valuePointer andObjCType:(const char*)objcType;

@end
