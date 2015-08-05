//
//  NSError+EVA.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/31/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "NSError+EVA.h"

@implementation NSError (EVA)

+ (NSError*)errorWithCode:(NSInteger)code andDescription:(NSString *)description {
    return [NSError errorWithDomain:@"com.evature.eva" code:code userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end
