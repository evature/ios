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
    CGFloat _minVolume;
    CGFloat _maxVolume;
    unsigned char _curPosOddEven;
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
        _curPosOddEven = 0;
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
    dataLength = dataLength / sizeof(CGFloat);
    
    int height_2 = self.bounds.size.height / 2;
    CGFloat width = self.bounds.size.width;
    CGFloat width_2 = width/2.0f;
    
    CGFloat delta = MAX(0.5f, _maxVolume - _minVolume);
    //CGFloat delta = _maxVolume - _minVolume;
    CGFloat xStep = width;
    if (dataLength != 0) {
        xStep /= (3.0f*dataLength);
    }
    
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
            CGFloat y = ((_curPosOddEven+i) % 2 == 0 ? -1 : 1) * normLevel;
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

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self redrawPath];
    CGPathRef backgroundPath = CGPathCreateWithEllipseInRect(bounds, NULL);
    self.shadowPath = backgroundPath;
    CFRelease(backgroundPath);
}

- (void)audioSessionStarted {
    self.hidden = NO;
    static CGFloat array[BUFFER_ELEMENT_COUNT] = {0.0f};
    _curPosOddEven = 0;
    [self newAudioLevelData:[NSData dataWithBytes:array length:sizeof(array)]];
}

- (void)audioSessionStoped {
    self.hidden = YES;
    TPCircularBufferClear(&_dataBuffer);
    [self redrawPath];
}

- (void)newAudioLevelData:(NSData*)data {
    if (!self.hidden) {
        if (_dataBuffer.fillCount >= BUFFER_SIZE) {
            TPCircularBufferConsume(&_dataBuffer, (int32_t)([data length]));
            _curPosOddEven = (_curPosOddEven + [data length] / sizeof(CGFloat))%2;
        }
        TPCircularBufferProduceBytes(&_dataBuffer, [data bytes], (int32_t)[data length]);
        [self redrawPath];
    }
}

- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    _minVolume = minVolume;
    _maxVolume = maxVolume;
//    if (!self.hidden) {
//        [self redrawPath];
//    }
}


@end
