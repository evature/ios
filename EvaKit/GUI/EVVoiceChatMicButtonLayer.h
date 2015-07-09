//
//  EVVoiceChatMicButtonLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface EVVoiceChatMicButtonLayer : CALayer {
    CGPathRef _micPath;
    CGColorRef _micLineColor;
    CGColorRef _micFillColor;
    CGColorRef _borderLineColor;
    CGColorRef _backgroundFillColor;
}

// All CG*Ref properties retains values. So release object after initializing.
@property (nonatomic, assign) CGColorRef micLineColor;
@property (nonatomic, assign) CGFloat micLineWidth;
@property (nonatomic, assign) CGColorRef micFillColor;
@property (nonatomic, assign) CGFloat micScaleFactor;

@property (nonatomic, assign) CGColorRef borderLineColor;
@property (nonatomic, assign) CGFloat borderLineWidth;
@property (nonatomic, assign) CGColorRef backgroundFillColor;

@property (nonatomic, assign) CGPathRef micPath;

- (void)setMicPathFromSVGFileWithPath:(NSString*)svgFilePath;

- (void)hideMicLayer;
- (void)showMicLayer;

- (void)startSpinning;
- (void)stopSpinning;

@end
