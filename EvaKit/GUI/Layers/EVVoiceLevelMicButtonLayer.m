//
//  EVVoiceLevelMicButtonLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceLevelMicButtonLayer.h"

#define BUFFER_ELEMENT_COUNT 16


@interface EVVoiceLevelMicButtonLayer () {
    CGFloat _minVolume;
    CGFloat _maxVolume;
    uint8_t _curPosOddEven;
    CGFloat volumeBuffer[BUFFER_ELEMENT_COUNT];
}

- (void)redrawPath;

@end

@implementation EVVoiceLevelMicButtonLayer

- (id)init {
    self = [super init];
    if (self != nil) {
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
    self.path = NULL;
    self.fillColor = nil;
    [super dealloc];
}

- (void)redrawPath {
    // Load data from circular buffer
    int32_t dataLength = (int32_t)(sizeof(volumeBuffer) / sizeof(CGFloat));
    
    int height_2 = self.bounds.size.height / 2;
    CGFloat width = self.bounds.size.width;
    CGFloat width_2 = width/2.0f;
    
    CGFloat delta = MAX(0.35f, _maxVolume - _minVolume);
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
    
    CGFloat Rsqr = height_2 * height_2;
    for (int i = 0; i < dataLength; i++) {
        CGFloat volume = fabs(volumeBuffer[i]);
        if (volume > 0.0f) {
            volume -= _minVolume;
        }
        CGFloat normLevel = volume / delta;
        CGFloat y = ((_curPosOddEven+i) % 2 == 0 ? -1 : 1) * normLevel;
        if (_isFishEyeEnabled) {
            CGFloat centerX = curX+centerStep;
            CGFloat x = fabs(centerX - width_2);
            y *= sqrt(Rsqr - x*x);
        } else {
            y *= height_2;
        }
        CGPathAddCurveToPoint(path, &translate, curX+xStep, y, curX+xStep2, y, curX+xStep3, 0);
        curX += xStep3;
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
    _curPosOddEven = 0;
    memset(volumeBuffer, 0, sizeof(volumeBuffer));
    [self redrawPath];
    self.hidden = NO;
}

- (void)audioSessionStoped {
    self.hidden = YES;
    memset(volumeBuffer, 0, sizeof(volumeBuffer));
    //[self redrawPath];
}

- (void)newAudioLevelData:(NSData*)data {
    if (!self.hidden) {
        uint32_t bufferSize = (uint32_t)sizeof(volumeBuffer);
        NSUInteger dataLength = [data length];
        uint8_t* volumeBytes = (uint8_t*)volumeBuffer;
        if (dataLength >= bufferSize) {
            memcpy(volumeBytes, [data bytes], bufferSize);
        } else {
            memmove(volumeBytes, volumeBytes+dataLength, bufferSize-dataLength);
            memcpy(volumeBytes+(bufferSize-dataLength), [data bytes], dataLength);
        }
        _curPosOddEven = (_curPosOddEven + [data length] / sizeof(CGFloat))%2;;
        [self redrawPath];
    }
}

- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    _minVolume = minVolume;
    _maxVolume = maxVolume;
}


@end
