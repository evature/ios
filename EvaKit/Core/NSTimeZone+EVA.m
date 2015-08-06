//
//  NSTimeZone+EVA.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/6/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "NSTimeZone+EVA.h"

@implementation NSTimeZone (EVA)

- (NSString*)stringOffsetFromGMT {
    NSInteger hoursFromGMT = [self secondsFromGMT]/3600;
    NSInteger minutesFromGMT = (([self secondsFromGMT])%3600)/60;
    
    if (hoursFromGMT>=0) {
        return [NSString stringWithFormat:@"+%02d:%02d",hoursFromGMT,minutesFromGMT];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d",hoursFromGMT,minutesFromGMT];
    }

}

@end
