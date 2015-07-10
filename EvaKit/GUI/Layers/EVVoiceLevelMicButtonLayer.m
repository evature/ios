//
//  EVVoiceLevelMicButtonLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceLevelMicButtonLayer.h"
#import "TPCircularBuffer.h"

#define BUFFER_ELEMENT_COUNT 16
#define BUFFER_SIZE BUFFER_ELEMENT_COUNT*sizeof(CGFloat)
#define EPSILON 1.0e-5


@interface EVVoiceLevelMicButtonLayer () {
    TPCircularBuffer _dataBuffer;
    BOOL _working;
    CGFloat _minVolume;
    CGFloat _maxVolume;
}

- (void)redrawPath;

@end

@implementation EVVoiceLevelMicButtonLayer

- (id)init {
    self = [super init];
    if (self != nil) {
        TPCircularBufferInit(&_dataBuffer, BUFFER_SIZE);
        self.fillColor = nil;
        self.lineCap = kCALineCapRound;
        self.extendLine = YES;
        self.isFishEyeEnabled = YES;
        self.graphAlignment = EVGraphAlignmentCenter;
    }
    return self;
}

- (void)dealloc {
    TPCircularBufferCleanup(&_dataBuffer);
    [super dealloc];
}

- (void)redrawPath {
    // Load data from circular buffer
    int32_t dataLength;
    CGFloat* volumes = TPCircularBufferTail(&_dataBuffer, &dataLength);
    if (dataLength == 0) {
        return;
    }
    dataLength = dataLength / sizeof(CGFloat);
    
    int height_2 = self.bounds.size.height / 2;
    CGFloat width = self.bounds.size.width;
    CGFloat width_2 = width/2.0f;
    
    CGFloat delta = MAX(50.0f, _maxVolume - _minVolume);
    CGFloat xStep = width / (3.0f*dataLength);
    CGFloat xStep2 = 2.0f*xStep;
    CGFloat centerStep = (1.5f*xStep);
    CGFloat xStep3 = 3.0f*xStep;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, height_2);
    
    CGFloat curX;
    switch (_graphAlignment) {
        case EVGraphAlignmentRight:
            curX = width - dataLength * xStep3;
            break;
        case EVGraphAlignmentCenter:
            curX = (width - dataLength * xStep3) / 2.0f;
            break;
        default:
            curX = 0.0f;
            break;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    if (_extendLine) {
        CGPathMoveToPoint(path, &translate, 0, 0);
        CGPathAddLineToPoint(path, &translate, curX, 0);
    } else {
        CGPathMoveToPoint(path, &translate, curX, 0);
    }
    if (dataLength > 4) {
        CGFloat Rsqr = height_2 * height_2;
        for (int i = 0; i < dataLength; i++) {
            CGFloat volume = fabs(volumes[i]);
            if (volume > 0.0f) {
                volume -= _minVolume;
            }
            CGFloat normLevel = volume / delta;
            CGFloat y = (i % 2 == 0 ? -1 : 1) * normLevel;
            if (_isFishEyeEnabled) {
                CGFloat centerX = curX+centerStep;
                CGFloat x = fabs(centerX - width_2);
                y *= sqrt(Rsqr - x*x);
            }
            else {
                y *= height_2;
            }
            CGPathAddCurveToPoint(path, &translate, curX+xStep, y, curX+xStep2, y, curX+xStep3, 0);
            curX += xStep3;
        }
    }
    if (_extendLine) {
        CGPathAddLineToPoint(path, &translate, width, 0);
    }
    self.path = path;
    CGPathRelease(path);
}

//- (void)redrawPath {
//    int32_t dataLength;
//    CGFloat* data = TPCircularBufferTail(&_dataBuffer, &dataLength);
//    CGFloat* volumes = (CGFloat*)malloc(dataLength+sizeof(CGFloat));
//    memcpy(volumes, data, dataLength);
//    dataLength = dataLength / sizeof(CGFloat);
//    volumes[dataLength] = (_maxVolume - _minVolume) / 2.0f;
//    dataLength+=1;
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGFloat widthStep = self.bounds.size.width / (CGFloat)(BUFFER_ELEMENT_COUNT+1);
//    CGFloat heightCenter = self.bounds.size.height / 2.0f;
//    CGFloat heightCoefficient = self.bounds.size.height/(_maxVolume - _minVolume);
//    
//    CGPathMoveToPoint(path, NULL, 0, heightCenter);
//    
//    NSInteger ii;
//    
//    for (ii=0; ii < dataLength-1; ++ii) {
//        CGPoint curPt, prevPt, nextPt, endPt;
//        
//        curPt.x = ii*widthStep;
//        curPt.y = (volumes[ii] - _minVolume)*heightCoefficient;
//        //if (ii==0)
//        //    CGPathMoveToPoint(path, NULL, curPt.x, curPt.y);
//        
//        NSInteger nextii = (ii+1)%dataLength;
//        NSInteger previi = (ii-1 < 0 ? dataLength-1 : ii-1);
//        
//        prevPt.x = previi*widthStep;
//        prevPt.y = (volumes[previi] - _minVolume)*heightCoefficient;
//        
//        nextPt.x = nextii*widthStep;
//        nextPt.y = (volumes[nextii] - _minVolume)*heightCoefficient;
//
//        endPt = nextPt;
//        
//        CGFloat mx, my;
//        if (ii > 0) {
//            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
//            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
//        }
//        else {
//            mx = (nextPt.x - curPt.x)*0.5;
//            my = (nextPt.y - curPt.y)*0.5;
//        }
//        
//        CGPoint ctrlPt1;
//        ctrlPt1.x = curPt.x + mx / 3.0;
//        ctrlPt1.y = curPt.y + my / 3.0;
//        
//        curPt.x = nextii*widthStep;
//        curPt.y = (volumes[nextii] - _minVolume)*heightCoefficient;
//        
//        nextii = (nextii+1)%dataLength;
//        previi = ii;
//        
//        prevPt.x = previi*widthStep;
//        prevPt.y = (volumes[previi] - _minVolume)*heightCoefficient;
//        
//        nextPt.x = nextii*widthStep;
//        nextPt.y = (volumes[nextii] - _minVolume)*heightCoefficient;
//        
//        if (ii < dataLength-2) {
//            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
//            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
//        }
//        else {
//            mx = (curPt.x - prevPt.x)*0.5;
//            my = (curPt.y - prevPt.y)*0.5;
//        }
//        
//        CGPoint ctrlPt2;
//        ctrlPt2.x = curPt.x - mx / 3.0;
//        ctrlPt2.y = curPt.y - my / 3.0;
//        
//        CGPathAddCurveToPoint(path, NULL, ctrlPt1.x, ctrlPt1.y, ctrlPt2.x, ctrlPt2.y, endPt.x, endPt.y);
//    }
//    free(volumes);
//    
////    int bindex = 0;
////    for (bindex = 0; bindex < dataLength; bindex++) {
////        CGFloat volume = volumes[bindex];
////        volume = (volume - _minVolume)*heightCoefficient;
////        CGPathAddLineToPoint(path, NULL, (bindex+1)*widthStep, height-volume);
////    }
//    //Line to 0 line. And then 0 line to end of view
//    //CGPathAddLineToPoint(path, NULL, ii*widthStep, self.bounds.size.height / 2.0f);
//    CGPathAddLineToPoint(path, NULL, self.bounds.size.width, heightCenter);
//    //CGPathCloseSubpath(path);
//    self.path = path;
//    CGPathRelease(path);
//}

//- (id<CAAction>)actionForKey:(NSString *)event {
//    if ([event isEqualToString:@"path"]) {
//        CABasicAnimation *animation = [CABasicAnimation
//                                       animationWithKeyPath:event];
//        animation.duration = 0.05;
//        animation.timingFunction = [CATransaction
//                                    animationTimingFunction];
//        return animation;
//    }
//    return [super actionForKey:event];
//}

- (void)audioSessionStarted {
    _working = YES;
    [self redrawPath];
}

- (void)audioSessionStoped {
    _working = NO;
    TPCircularBufferClear(&_dataBuffer);
}

- (void)newAudioLevelData:(NSData*)data {
    if (_working) {
        if (_dataBuffer.fillCount > BUFFER_SIZE) {
            TPCircularBufferConsume(&_dataBuffer, (int32_t)([data length]));
        }
        TPCircularBufferProduceBytes(&_dataBuffer, [data bytes], (int32_t)[data length]);
        [self redrawPath];
    }
}

- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    _minVolume = minVolume;
    _maxVolume = maxVolume;
    if (_working) {
        [self redrawPath];
    }
}

@end
