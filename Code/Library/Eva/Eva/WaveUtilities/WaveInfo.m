//
//  WaveInfo.m
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import "WaveInfo.h"

@implementation WaveInfo

-(int)numberOfCompleteFramesForFrameSize:(int)frameSize {
    return ( self.numberOfSamples / frameSize );
}

-(int)numberOfRemainingSamplesForFrameSize:(int)frameSize {
    return ( self.numberOfSamples - ( [self numberOfCompleteFramesForFrameSize:frameSize] * frameSize ) );
}

@end