//
//  EVVoiceChatMicButtonLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatMicButtonLayer.h"
#import "EVSVGLayer.h"
#import "EVVoiceLevelMicButtonLayer.h"
#import <UIKit/UIKit.h>

NSString* const kEVRotatingAnimationKey = @"kEVRotatingAnimationKey";
NSString* const kEVStrokeAnimationKey = @"kEVStrokeAnimationKey";


@interface EVVoiceChatMicButtonLayer () {
    CGFloat _oldBorderLineWidth;
}

@property (nonatomic, retain) EVVoiceLevelMicButtonLayer* voiceGraphLayer;

@end

@implementation EVVoiceChatMicButtonLayer

@dynamic highlightColor;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setImageFromSVGFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"EvaKit_Mic" ofType:@"svg"]];
        
        self.voiceGraphLayer = [EVVoiceLevelMicButtonLayer layer];
        self.voiceGraphLayer.zPosition = 1500.0f;
        self.voiceGraphLayer.strokeColor = self.borderLineColor;
        self.voiceGraphLayer.lineWidth = self.borderLineWidth > 0.0f ? self.borderLineWidth : 1.0f;
        self.voiceGraphLayer.hidden = YES;
        _oldBorderLineWidth = self.borderLineWidth;
        [self addSublayer:self.voiceGraphLayer];
        
        EVResizableShapeLayer* highlight = [EVResizableShapeLayer layer];
        CGPathRef highlightPath = CGPathCreateWithEllipseInRect(CGRectMake(0.0f, 0.0f, 240.0f, 240.0f), NULL);
        highlight.path = highlightPath;
        CFRelease(highlightPath);
        self.highlightLayer = highlight;
        
    }
    return self;
}

- (void)dealloc {
    self.highlightColor = NULL;
    [super dealloc];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self.voiceGraphLayer setBounds:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width-3.0f, bounds.size.height)];
    self.voiceGraphLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setBorderLineWidth:(CGFloat)borderLineWidth {
    [super setBorderLineWidth:borderLineWidth];
    _oldBorderLineWidth = borderLineWidth;
    self.voiceGraphLayer.lineWidth = borderLineWidth > 0.0f ? borderLineWidth : 1.0f;
    if (_spinningBorderWidth < 0.001f) {
        _spinningBorderWidth = borderLineWidth;
    }
}

- (void)setBorderLineColor:(CGColorRef)borderLineColor {
    [super setBorderLineColor:borderLineColor];
    self.voiceGraphLayer.strokeColor = borderLineColor;
}

- (void)audioSessionStarted {
    [self.voiceGraphLayer audioSessionStarted];
}

- (void)audioSessionStoped {
    [self.voiceGraphLayer audioSessionStoped];
}

- (void)newAudioLevelData:(NSData*)data {
    [self.voiceGraphLayer newAudioLevelData:data];
    
}
- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    [self.voiceGraphLayer newMinVolume:minVolume andMaxVolume:maxVolume];
}

- (CGColorRef)highlightColor {
    return ((EVResizableShapeLayer*)self.highlightLayer).fillColor;
}

- (void)setHighlightColor:(CGColorRef)highlightColor {
    ((EVResizableShapeLayer*)self.highlightLayer).fillColor = highlightColor;
}

- (void)hideMic {
    self.imageLayer.transform = CATransform3DMakeRotation(M_PI_2, 1.0f, 0.0f, 0.0f);
}

- (void)showMic {
    //[self.imageLayer setBounds:self.imageLayer.bounds];
    self.imageLayer.transform = CATransform3DIdentity;
}

- (void)startSpinning {
    CAMediaTimingFunction* timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 4.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.backgroundLayer addAnimation:animation forKey:kEVRotatingAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = timingFunction;
    
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    [(EVSVGLayer*)self.backgroundLayer setLineWidth:(_spinningBorderWidth > 0.9f ? _spinningBorderWidth : 2.0f)];
    [self.backgroundLayer addAnimation:animations forKey:kEVStrokeAnimationKey];
}

- (void)stopSpinning {
    [(EVSVGLayer*)self.backgroundLayer setLineWidth:_oldBorderLineWidth];
    [self.backgroundLayer removeAnimationForKey:kEVRotatingAnimationKey];
    [self.backgroundLayer removeAnimationForKey:kEVStrokeAnimationKey];
}

@end
