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
    }
    return self;
}

- (void)dealloc {
    TPCircularBufferCleanup(&_dataBuffer);
    [super dealloc];
}

- (void)redrawPath {
    int32_t dataLendth;
    CGFloat* volumes = TPCircularBufferTail(&_dataBuffer, &dataLendth);
    dataLendth = dataLendth / sizeof(CGFloat);
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat widthStep = self.bounds.size.width / (CGFloat)BUFFER_ELEMENT_COUNT;
    CGPathMoveToPoint(path, NULL, 0, 0);
    int bindex = 0;
    for (bindex = 0; bindex < dataLendth; bindex++) {
        CGFloat volume = volumes[bindex];
        CGPathAddLineToPoint(path, NULL, bindex*widthStep, volume);
    }
    //Line to 0 line. And then 0 line to end of view
    CGPathAddLineToPoint(path, NULL, bindex*widthStep, 0);
    CGPathAddLineToPoint(path, NULL, BUFFER_ELEMENT_COUNT*widthStep, 0);
    CGPathCloseSubpath(path);
    self.path = path;
    CGPathRelease(path);
}

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
        int32_t freeBytes;
        TPCircularBufferHead(&_dataBuffer, &freeBytes);
        if (freeBytes < [data length]) {
            TPCircularBufferConsume(&_dataBuffer, (int32_t)([data length] - freeBytes));
        }
        TPCircularBufferProduceBytes(&_dataBuffer, [data bytes], (int32_t)[data length]);
        [self redrawPath];
    }
}

- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    if (_working) {
        _minVolume = minVolume;
        _maxVolume = maxVolume;
        [self redrawPath];
    }
}

@end
