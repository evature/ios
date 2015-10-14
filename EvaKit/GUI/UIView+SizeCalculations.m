//
//  UIView+SizeCalculations.m
//  EvaKit
//
//  Created by Yegor Popovych on 9/29/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "UIView+SizeCalculations.h"

@implementation UIView (SizeCalculations)

+ (CGFloat)recalculateSizeForDeviceFrom1xSize:(CGFloat)size1x {
    CGFloat scale = [UIScreen mainScreen].scale;
    scale = scale > 2.0 ? 2.0 : scale;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return size1x*2;
    }
    return size1x*scale;
}

- (CGFloat)recalculateSizeForDeviceFrom1xSize:(CGFloat)size1x {
    return [[self class] recalculateSizeForDeviceFrom1xSize:size1x];
}

@end
