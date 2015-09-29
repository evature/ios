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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return size1x*2*[UIScreen mainScreen].scale;
    }
    return size1x*[UIScreen mainScreen].scale;
}

- (CGFloat)recalculateSizeForDeviceFrom1xSize:(CGFloat)size1x {
    return [[self class] recalculateSizeForDeviceFrom1xSize:size1x];
}

@end
