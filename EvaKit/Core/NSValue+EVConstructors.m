//
//  NSValue+EVConstructors.m
//  EvaKit
//
//  Created by Yegor Popovych on 9/25/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "NSValue+EVConstructors.h"

@implementation NSValue (EVConstructors)

+ (id)ev_valueWithValue:(const void*)value andObjCType:(const char*)objcType {
    if (objcType[0] == '@') {
        return [self valueWithNonretainedObject:*((id*)value)];
    }
    if (objcType[0] == '^') {
        return [self valueWithPointer:*((const void**)value)];
    }
    if (strlen(objcType) == 1) {
        if (objcType[0] == @encode(BOOL)[0]) {
            return [NSNumber numberWithBool:*((const BOOL*)value)];
        }
        if (objcType[0] == @encode(char)[0]) {
            return [NSNumber numberWithChar:*((const char*)value)];
        }
        if (objcType[0] == @encode(unsigned char)[0]) {
            return [NSNumber numberWithUnsignedChar:*((const unsigned char*)value)];
        }
        if (objcType[0] == @encode(double)[0]) {
            return [NSNumber numberWithDouble:*((const double*)value)];
        }
        if (objcType[0] == @encode(float)[0]) {
            return [NSNumber numberWithFloat:*((const float*)value)];
        }
        if (objcType[0] == @encode(int)[0]) {
            return [NSNumber numberWithInt:*((const int*)value)];
        }
        if (objcType[0] == @encode(unsigned int)[0]) {
            return [NSNumber numberWithUnsignedInt:*((const unsigned int*)value)];
        }
        if (objcType[0] == @encode(NSInteger)[0]) {
            return [NSNumber numberWithInteger:*((const NSInteger*)value)];
        }
        if (objcType[0] == @encode(NSUInteger)[0]) {
            return [NSNumber numberWithUnsignedInteger:*((const NSUInteger*)value)];
        }
        if (objcType[0] == @encode(long)[0]) {
            return [NSNumber numberWithLong:*((const long*)value)];
        }
        if (objcType[0] == @encode(unsigned long)[0]) {
            return [NSNumber numberWithUnsignedLong:*((const unsigned long*)value)];
        }
        if (objcType[0] == @encode(long long)[0]) {
            return [NSNumber numberWithLongLong:*((const long long*)value)];
        }
        if (objcType[0] == @encode(unsigned long long)[0]) {
            return [NSNumber numberWithUnsignedLongLong:*((const unsigned long long*)value)];
        }
        if (objcType[0] == @encode(short)[0]) {
            return [NSNumber numberWithShort:*((const short*)value)];
        }
        if (objcType[0] == @encode(unsigned short)[0]) {
            return [NSNumber numberWithUnsignedShort:*((const unsigned short*)value)];
        }
    }
    return [self valueWithBytes:value objCType:objcType];
}

@end
