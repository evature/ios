//
//  EVSpringAnimation.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/19/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface EVSpringAnimation : CAKeyframeAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path
                            duration:(NSTimeInterval)duration
              usingSpringWithDumping:(CGFloat)dumping
                     initialVelocity:(CGFloat)velocity
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue;


- (instancetype)initWithKeyPath:(NSString *)path
                       duration:(NSTimeInterval)duration
         usingSpringWithDumping:(CGFloat)dumping
                initialVelocity:(CGFloat)velocity
                      fromValue:(CGFloat)fromValue
                        toValue:(CGFloat)toValue;

@end
