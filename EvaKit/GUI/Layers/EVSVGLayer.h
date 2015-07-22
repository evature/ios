//
//  EVSVGLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVResizableShapeLayer.h"

@interface EVSVGLayer : EVResizableShapeLayer

+ (instancetype)layerWithSVGPath:(NSString*)svgPath;
- (instancetype)initWithSVGPath:(NSString*)svgPath;

- (void)showSVGFileAtPath:(NSString*)svgPath;

@end
