//
//  EVVoiceChatMicButtonLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatMicButtonLayer.h"
#import "PocketSVG.h"

NSString* const kEVRotatingAnimationKey = @"kEVRotatingAnimationKey";
NSString* const kEVStrokeAnimationKey = @"kEVStrokeAnimationKey";
#define BACKGROUND_PATH_SIZE 240.0f

@interface EVVoiceChatMicButtonLayer () {
    BOOL _observersAdded;
}

@property (nonatomic, retain) CAShapeLayer* micLayer;
@property (nonatomic, retain) CAShapeLayer* backgroundLayer;

- (CGAffineTransform)calculateSizeTransformForPath:(CGPathRef)path withScale:(CGFloat)scale andLineWidth:(CGFloat)lineWidth forRect:(CGRect)frame ;

@end

@implementation EVVoiceChatMicButtonLayer

@dynamic micLineColor;
@dynamic micPath;
@dynamic micFillColor;
@dynamic borderLineColor;
@dynamic backgroundFillColor;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.backgroundLayer = [CAShapeLayer layer];
        self.micLayer = [CAShapeLayer layer];
        [self setMicPathFromSVGFileWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Mic" ofType:@"svg"]];
        self.micLayer.bounds = CGPathGetBoundingBox(self.micLayer.path);
        self.micLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.micLayer.zPosition = 1000.0f;
        self.backgroundLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0.0f, 0.0f, BACKGROUND_PATH_SIZE, BACKGROUND_PATH_SIZE), NULL);
        self.backgroundLayer.bounds = CGPathGetBoundingBox(self.backgroundLayer.path);
        self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.backgroundLayer.zPosition = 0.0f;
        [self addObserver:self forKeyPath:@"micLineWidth" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"borderLineWidth" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"micScaleFactor" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
        _observersAdded = YES;
        [self addSublayer:self.backgroundLayer];
        [self addSublayer:self.micLayer];
    }
    return self;
}

- (void)dealloc {
    if (_observersAdded) {
        [self removeObserver:self forKeyPath:@"micLineWidth"];
        [self removeObserver:self forKeyPath:@"borderLineWidth"];
        [self removeObserver:self forKeyPath:@"micScaleFactor"];
    }
    self.micPath = NULL;
    self.micLineColor = NULL;
    self.micLayer = nil;
    self.backgroundLayer = nil;
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.micLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.backgroundLayer setAffineTransform:[self calculateSizeTransformForPath:self.backgroundLayer.path withScale:1.0f andLineWidth:self.borderLineWidth forRect:self.bounds]];
    [self.micLayer setAffineTransform:[self calculateSizeTransformForPath:self.micLayer.path withScale:self.micScaleFactor andLineWidth:self.micLineWidth forRect:self.bounds]];
}


- (void)layoutSublayers {
    [super layoutSublayers];
}

- (CGAffineTransform)calculateSizeTransformForPath:(CGPathRef)path withScale:(CGFloat)scale andLineWidth:(CGFloat)lineWidth forRect:(CGRect)frame {
    CGRect boundingBox = CGPathGetBoundingBox(path);
    boundingBox.size.width += lineWidth;
    boundingBox.size.height += lineWidth;
    CGFloat boundingBoxAspectRatio = CGRectGetWidth(boundingBox)/CGRectGetHeight(boundingBox);
    CGFloat viewAspectRatio = CGRectGetWidth(frame)/CGRectGetHeight(frame);
    if (boundingBoxAspectRatio > viewAspectRatio) {
        // Width is limiting factor
        scale *= CGRectGetWidth(frame)/CGRectGetWidth(boundingBox);
    } else {
        // Height is limiting factor
        scale *= CGRectGetHeight(frame)/CGRectGetHeight(boundingBox);
    }
    // Scaling the path ...
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    // Scale down the path first
    scaleTransform = CGAffineTransformScale(scaleTransform, scale, scale);
    return scaleTransform;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"micLineWidth"]) {
        self.micLayer.lineWidth = self.micLineWidth;
    } else if ([keyPath isEqualToString:@"borderLineWidth"]) {
        self.backgroundLayer.lineWidth = self.borderLineWidth;
    } else if ([keyPath isEqualToString:@"micScaleFactor"]) {
        [self setNeedsLayout];
    }
}

- (CGPathRef)micPath {
    return _micPath;
}

- (void)setMicPathFromSVGFileWithPath:(NSString*)svgFilePath {
    self.micPath = CGPathCreateCopy([PocketSVG pathFromSVGFileAtURL:[NSURL fileURLWithPath:svgFilePath]]);
    CFRelease(_micPath);
}

- (void)setMicPath:(CGPathRef)micPath {
    if (_micPath != NULL) {
        CFRelease(_micPath);
    }
    _micPath = micPath;
    self.micLayer.path = _micPath;
    if (_micPath != NULL) {
        CFRetain(_micPath);
    }
}

- (CGColorRef)micLineColor {
    return _micLineColor;
}

- (void)setMicLineColor:(CGColorRef)micLineColor {
    if (_micLineColor != NULL) {
        CFRelease(_micLineColor);
    }
    _micLineColor = micLineColor;
    self.micLayer.strokeColor = micLineColor;
    if (_micLineColor != NULL) {
        CFRetain(_micLineColor);
    }
}

- (CGColorRef)micFillColor {
    return _micFillColor;
}

- (void)setMicFillColor:(CGColorRef)micFillColor {
    if (_micFillColor != NULL) {
        CFRelease(_micFillColor);
    }
    _micFillColor = micFillColor;
    self.micLayer.fillColor = micFillColor;
    if (_micFillColor != NULL) {
        CFRetain(_micFillColor);
    }
}

- (CGColorRef)borderLineColor {
    return _borderLineColor;
}

- (void)setBorderLineColor:(CGColorRef)borderLineColor {
    if (_borderLineColor != NULL) {
        CFRelease(_borderLineColor);
    }
    _borderLineColor = borderLineColor;
    self.backgroundLayer.strokeColor = borderLineColor;
    if (_borderLineColor != NULL) {
        CFRetain(_borderLineColor);
    }
}

- (CGColorRef)backgroundFillColor {
    return _backgroundFillColor;
}

- (void)setBackgroundFillColor:(CGColorRef)backgroundFillColor {
    if (_backgroundFillColor != NULL) {
        CFRelease(_backgroundFillColor);
    }
    _backgroundFillColor = backgroundFillColor;
    self.backgroundLayer.fillColor = backgroundFillColor;
    if (_backgroundFillColor != NULL) {
        CFRetain(_backgroundFillColor);
    }
}

- (void)hideMicLayer {
    self.micLayer.transform = CATransform3DRotate(self.micLayer.transform, M_PI_2, 1.0f, 0.0f, 0.0f);
}

- (void)showMicLayer {
    [self.micLayer setAffineTransform:[self calculateSizeTransformForPath:self.micLayer.path withScale:self.micScaleFactor andLineWidth:self.micLineWidth forRect:self.bounds]];
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
    [self.backgroundLayer addAnimation:animations forKey:kEVStrokeAnimationKey];
}

- (void)stopSpinning {
    [self.backgroundLayer removeAnimationForKey:kEVRotatingAnimationKey];
    [self.backgroundLayer removeAnimationForKey:kEVStrokeAnimationKey];
}

@end
