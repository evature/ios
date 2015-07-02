//
//  SpeexEncoder.h
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speex/Speex.h>

// This value is picked quite arbitrarily here.
#define MAX_FRAMES_PER_OGG_PAGE 79

@interface SpeexEncoder : NSObject

@property (nonatomic, readonly) SpeexQuality encodingQuality;
@property (nonatomic, readonly) SpeexMode encodingMode;
@property (nonatomic, readonly) SampleRate outSampleRate;

/***
 * @Description: Creates an object responsible for encoding different audio types into speex.
 * @Return: Returns the encoder.
 */
+(SpeexEncoder *)encoderWithMode:(SpeexMode)mode quality:(SpeexQuality)quality outputSampleRate:(SampleRate)outSampleRate;

/***
 * @Description: Encodes wave pcm file at specified path into speex.
 * @Return: Returns encoded data or nil if error occured (for details see error.description).
 * @Notes: Stereo wave pcm is UNSUPPORTED in this version.
 */
-(NSData *)encodeWaveFileAtPath:(NSString *)path error:(NSError **)error;

@end
