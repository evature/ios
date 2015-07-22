//
//  EVResizableShapeLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


// This layer automatically calculates scale transform matrix.
@interface EVResizableShapeLayer : CAShapeLayer

@property (nonatomic, assign) CGFloat pathScale;

@end
