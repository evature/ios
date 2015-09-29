//
//  UIView+SizeCalculations.h
//  EvaKit
//
//  Created by Yegor Popovych on 9/29/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SizeCalculations)

+ (CGFloat)recalculateSizeForDeviceFrom1xSize:(CGFloat)size1x;

- (CGFloat)recalculateSizeForDeviceFrom1xSize:(CGFloat)size1x;

@end
