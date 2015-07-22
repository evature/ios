//
//  EVSVGButtonWithCircleBackgroundLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVButtonLayer.h"

@interface EVSVGButtonWithCircleBackgroundLayer : EVButtonLayer

@property (nonatomic, assign) CGFloat svgLineWidth;
@property (nonatomic, assign) CGFloat borderLineWidth;

@property (nonatomic, assign) CGFloat svgScaleFactor;
@property (nonatomic, assign) CGFloat backgroundScaleFactor;

@property (nonatomic, assign) CGColorRef svgLineColor;
@property (nonatomic, assign) CGColorRef svgFillColor;

@property (nonatomic, assign) CGColorRef borderLineColor;
@property (nonatomic, assign) CGColorRef backgroundFillColor;

- (void)setImageFromSVGFile:(NSString*)path;

@end
