//
//  WaveInfo.h
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaveInfo : NSObject

@property (strong) NSNumber *dataChunkIdPosition;
@property (strong) NSNumber *sampleRate;
@property () int bitsPerSample;
@property () int bytesPerSample;
@property () int numberOfSamples;
@property () int audioSize;
@property (strong) NSData *audioData;

-(int)numberOfCompleteFramesForFrameSize:(int)frameSize;
-(int)numberOfRemainingSamplesForFrameSize:(int)frameSize;

@end
