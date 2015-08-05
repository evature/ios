//
//  NSError+EVA.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/31/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERROR_STR_TO_CODE(__4char_str) ((int32_t)__4char_str)

@interface NSError (EVA)

+ (NSError*)errorWithCode:(NSInteger)code andDescription:(NSString*)description;

@end
