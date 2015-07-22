//
//  EVResizableShapeLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVResizableShapeLayer.h"
#import <UIKit/UIKit.h>

@interface EVResizableShapeLayer () {
    CGPathRef _originalPath;
    CGFloat _pathScale;
}

@end

@implementation EVResizableShapeLayer

@dynamic pathScale;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _pathScale = 1.0f;
        _originalPath = NULL;
    }
    return self;
}

- (void)dealloc {
    if (_originalPath != NULL) {
        CFRelease(_originalPath);
    }
    [super dealloc];
}

- (CGPathRef)scaledPath {
    CGFloat scale = self.pathScale;
    CGRect boundingBox = CGPathGetBoundingBox(_originalPath);
    CGRect selfBounds = self.bounds;
    selfBounds.size.width -= self.lineWidth+0.5f;
    selfBounds.size.height -= self.lineWidth+0.5f;
    CGFloat boundingBoxAspectRatio = CGRectGetWidth(boundingBox)/CGRectGetHeight(boundingBox);
    CGFloat viewAspectRatio = CGRectGetWidth(selfBounds)/CGRectGetHeight(selfBounds);
    if (boundingBoxAspectRatio > viewAspectRatio) {
        // Width is limiting factor
        scale *= CGRectGetWidth(selfBounds)/CGRectGetWidth(boundingBox);
    } else {
        // Height is limiting factor
        scale *= CGRectGetHeight(selfBounds)/CGRectGetHeight(boundingBox);
    }
    // Scaling the path ...
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    // Scale down the path first
    scaleTransform = CGAffineTransformScale(scaleTransform, scale, scale);
    // Then translate the path to the upper left corner
    scaleTransform = CGAffineTransformTranslate(scaleTransform, -CGRectGetMinX(boundingBox), -CGRectGetMinY(boundingBox));
    
    // If you want to be fancy you could also center the path in the view
    // i.e. if you don't want it to stick to the top.
    // It is done by calculating the heigth and width difference and translating
    // half the scaled value of that in both x and y (the scaled side will be 0)
    CGSize scaledSize = CGSizeApplyAffineTransform(boundingBox.size, CGAffineTransformMakeScale(scale, scale));
    CGSize centerOffset = CGSizeMake((CGRectGetWidth(selfBounds)+self.lineWidth+0.5f-scaledSize.width)/(scale*2.0),
                                     (CGRectGetHeight(selfBounds)+self.lineWidth+0.5f-scaledSize.height)/(scale*2.0));
    scaleTransform = CGAffineTransformTranslate(scaleTransform, centerOffset.width, centerOffset.height);
    // End of "center in view" transformation code
    
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(_originalPath,
                                                              &scaleTransform);
    return scaledPath;
}


- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    if (_originalPath != NULL) {
        CFRetain(_originalPath);
        self.path = _originalPath;
        CFRelease(_originalPath);
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    [super setLineWidth:lineWidth];
    if (_originalPath != NULL) {
        CFRetain(_originalPath);
        self.path = _originalPath;
        CFRelease(_originalPath);
    }
}

- (void)setPath:(CGPathRef)path {
    if (_originalPath != NULL) {
        CFRelease(_originalPath);
    }
    _originalPath = path;
    if (_originalPath != NULL) {
        CFRetain(_originalPath);
    }
    if (_originalPath != NULL && !CGRectIsEmpty(self.bounds)) {
        CGPathRef scaledPath = [self scaledPath];
        [super setPath:scaledPath];
        CFRelease(scaledPath);
    } else {
        [super setPath:path];
    }
    
}

- (CGFloat)pathScale {
    return _pathScale;
}

- (void)setPathScale:(CGFloat)pathScale {
    _pathScale = pathScale;
    if (_originalPath != NULL) {
        CFRetain(_originalPath);
        self.path = _originalPath;
        CFRelease(_originalPath);
    }
}

@end
