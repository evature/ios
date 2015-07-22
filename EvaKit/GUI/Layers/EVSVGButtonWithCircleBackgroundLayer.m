//
//  EVSVGButtonWithCircleBackgroundLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSVGButtonWithCircleBackgroundLayer.h"
#import "EVSVGLayer.h"

#define BACKGROUND_PATH_SIZE 240.0f

@implementation EVSVGButtonWithCircleBackgroundLayer

@dynamic svgLineWidth;
@dynamic borderLineWidth;

@dynamic svgScaleFactor;
@dynamic backgroundScaleFactor;

@dynamic svgLineColor;
@dynamic svgFillColor;

@dynamic borderLineColor;
@dynamic backgroundFillColor;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.backgroundLayer = [EVResizableShapeLayer layer];
        ((EVResizableShapeLayer*)self.backgroundLayer).strokeColor = self.borderLineColor;
        ((EVResizableShapeLayer*)self.backgroundLayer).lineWidth = self.borderLineWidth;
        ((EVResizableShapeLayer*)self.backgroundLayer).fillColor = self.backgroundFillColor;
        ((EVResizableShapeLayer*)self.backgroundLayer).pathScale = self.backgroundScaleFactor;
        [self.backgroundLayer setFrame:self.bounds];
        CGPathRef backgroundPath = CGPathCreateWithEllipseInRect(CGRectMake(0.0f, 0.0f, BACKGROUND_PATH_SIZE, BACKGROUND_PATH_SIZE), NULL);
        ((EVSVGLayer*)self.backgroundLayer).path = backgroundPath;
        CFRelease(backgroundPath);
        
        self.imageLayer = [EVSVGLayer layer];
        ((EVSVGLayer*)self.imageLayer).strokeColor = self.svgLineColor;
        ((EVSVGLayer*)self.imageLayer).fillColor = self.svgFillColor;
        ((EVSVGLayer*)self.imageLayer).lineWidth = self.svgLineWidth;
        ((EVSVGLayer*)self.imageLayer).pathScale = self.svgScaleFactor;
    }
    return self;
}

- (void)setImageFromSVGFile:(NSString*)path {
    [(EVSVGLayer*)self.imageLayer showSVGFileAtPath:path];
}

#pragma mark Setters and Getters (pass to layers)

- (CGFloat)svgLineWidth {
    return ((EVResizableShapeLayer*)self.imageLayer).lineWidth;
}

- (void)setSvgLineWidth:(CGFloat)svgLineWidth {
    ((EVResizableShapeLayer*)self.imageLayer).lineWidth = svgLineWidth;
}

- (CGFloat)borderLineWidth {
    return ((EVResizableShapeLayer*)self.backgroundLayer).lineWidth;
}

- (void)setBorderLineWidth:(CGFloat)borderLineWidth {
    ((EVResizableShapeLayer*)self.backgroundLayer).lineWidth = borderLineWidth;
}

- (CGFloat)svgScaleFactor {
    return ((EVResizableShapeLayer*)self.imageLayer).pathScale;
}

- (void)setSvgScaleFactor:(CGFloat)svgScaleFactor {
    ((EVResizableShapeLayer*)self.imageLayer).pathScale = svgScaleFactor;
}

- (CGFloat)backgroundScaleFactor {
    return ((EVResizableShapeLayer*)self.backgroundLayer).pathScale;
}

- (void)setBackgroundScaleFactor:(CGFloat)backgroundScaleFactor {
    ((EVResizableShapeLayer*)self.backgroundLayer).pathScale = backgroundScaleFactor;
}

- (CGColorRef)svgLineColor {
    return ((EVResizableShapeLayer*)self.imageLayer).strokeColor;
}

- (void)setSvgLineColor:(CGColorRef)svgLineColor {
    ((EVResizableShapeLayer*)self.imageLayer).strokeColor = svgLineColor;
}

- (CGColorRef)svgFillColor {
    return ((EVResizableShapeLayer*)self.imageLayer).fillColor;
}

- (void)setSvgFillColor:(CGColorRef)svgFillColor {
    ((EVResizableShapeLayer*)self.imageLayer).fillColor = svgFillColor;
}

- (CGColorRef)borderLineColor {
    return ((EVResizableShapeLayer*)self.backgroundLayer).strokeColor;
}

- (void)setBorderLineColor:(CGColorRef)borderLineColor {
    ((EVResizableShapeLayer*)self.backgroundLayer).strokeColor = borderLineColor;
}

- (CGColorRef)backgroundFillColor {
    return ((EVResizableShapeLayer*)self.backgroundLayer).fillColor;
}

- (void)setBackgroundFillColor:(CGColorRef)backgroundFillColor {
    ((EVResizableShapeLayer*)self.backgroundLayer).fillColor = backgroundFillColor;
}

@end
