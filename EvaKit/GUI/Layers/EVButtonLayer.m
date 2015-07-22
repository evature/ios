//
//  EVButtonLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVButtonLayer.h"
#import <UIKit/UIKit.h>

@implementation EVButtonLayer

@dynamic highlightLayer;
@dynamic backgroundLayer;
@dynamic imageLayer;

- (CALayer*)imageLayer {
    return _imageLayer;
}

- (CALayer*)backgroundLayer {
    return _backgroundLayer;
}

- (CALayer*)highlightLayer {
    return _highlightLayer;
}

- (void)setImageLayer:(CALayer *)imageLayer {
    if (_imageLayer != nil) {
        [_imageLayer removeFromSuperlayer];
        [imageLayer release];
    }
    _imageLayer = imageLayer;
    [_imageLayer retain];
    _imageLayer.zPosition = 1000.0f;
    
    [_imageLayer setFrame:self.bounds];
    _imageLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSublayer:_imageLayer];
}

- (void)setHighlightLayer:(CALayer *)highlightLayer {
    if (_highlightLayer != nil) {
        [_highlightLayer removeFromSuperlayer];
        [highlightLayer release];
    }
    _highlightLayer = highlightLayer;
    [_highlightLayer retain];
    _highlightLayer.zPosition = 2000.0f;

    [_highlightLayer setFrame:self.bounds];
    _highlightLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _highlightLayer.hidden = YES;
    [self addSublayer:_highlightLayer];
}

- (void)setBackgroundLayer:(CALayer *)backgroundLayer {
    if (_backgroundLayer != nil) {
        [_backgroundLayer removeFromSuperlayer];
        [backgroundLayer release];
    }
    _backgroundLayer = backgroundLayer;
    [_backgroundLayer retain];
    _backgroundLayer.zPosition = 0.0f;
    
    [_backgroundLayer setFrame:self.bounds];
    _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSublayer:_backgroundLayer];
}

- (void)touched {
    if (_highlightLayer != nil) {
        _highlightLayer.hidden = NO;
    }
}

- (void)released {
    if (_highlightLayer != nil) {
        _highlightLayer.hidden = YES;
    }
}

- (void)dealloc {
    [_backgroundLayer release], _backgroundLayer = nil;
    [_highlightLayer release], _highlightLayer = nil;
    [_imageLayer release], _imageLayer = nil;
    [super dealloc];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [_backgroundLayer setBounds:self.bounds];
    [_imageLayer setBounds:self.bounds];
    [_highlightLayer setBounds:self.bounds];
    _backgroundLayer.position = _imageLayer.position = _highlightLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (CALayer*)hitTest:(CGPoint)p {
    return [self containsPoint:[self convertPoint:p fromLayer:self.superlayer]] ? self : nil;
}

@end
