//
//  EVSpringAnimation.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/19/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSpringAnimation.h"

#define NUMBER_OF_ANIMATION_POINTS 500

@interface EVSpringAnimation ()

- (NSArray*)animationValuesFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue usingSpringWithDumping:(CGFloat)dumping andInitialVelocity:(CGFloat)velocity;

@end

@implementation EVSpringAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path
                            duration:(NSTimeInterval)duration
              usingSpringWithDumping:(CGFloat)dumping
                     initialVelocity:(CGFloat)velocity
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue {
    return [[[self alloc] initWithKeyPath:path
                                duration:duration
                  usingSpringWithDumping:dumping
                         initialVelocity:velocity
                               fromValue:fromValue
                                 toValue:toValue] autorelease];
}


- (instancetype)initWithKeyPath:(NSString *)path
                       duration:(NSTimeInterval)duration
         usingSpringWithDumping:(CGFloat)dumping
                initialVelocity:(CGFloat)velocity
                      fromValue:(CGFloat)fromValue
                        toValue:(CGFloat)toValue {
    self = [super init];
    if (self != nil) {
        self.keyPath = path;
        self.duration = duration;
        self.values = [self animationValuesFromValue:fromValue toValue:toValue usingSpringWithDumping:(dumping*10.0) andInitialVelocity:(velocity*10.0)];
    }
    return self;
}

- (NSArray*)animationValuesFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue usingSpringWithDumping:(CGFloat)dumping andInitialVelocity:(CGFloat)velocity {
    int numOfPoints = NUMBER_OF_ANIMATION_POINTS;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:numOfPoints];
    CGFloat distanceBetweenValues = toValue - fromValue;
    
    for (int point = 0; point < numOfPoints; point++) {
        CGFloat x = (double)point / (double)numOfPoints;
        CGFloat valueNormalized = pow(M_E, -dumping * x) * cos(velocity * x);
        CGFloat value = toValue - distanceBetweenValues * valueNormalized;
        [values addObject:@(value)];
    }
    
    return [NSArray arrayWithArray:values];
}

@end
