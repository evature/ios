//
//  NSDate+EVA.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/25/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (EVA)

+ (instancetype)dateWithEvaString:(NSString*)evaString;

- (instancetype)dateByAddingDays:(NSInteger)days;
- (instancetype)dateByAddingHours:(NSInteger)hours;

@end
