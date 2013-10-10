//
//  AudioFileWrapperController.h
//  SpeexKit
//
//  Created by Halle Winkler on 2/25/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class  AudioFileWrapperController
 @brief  A class that converts buffers into complete audio files of either WAV or Speex/OGG.
 */

@interface AudioFileWrapperController : NSObject {
 
    BOOL verboseAudioFileWrapperController;
    
}

@property(nonatomic,assign)    BOOL verboseAudioFileWrapperController;
/**Writes out a WAV file from a buffer*/
- (NSError *) writeWavFileFromMonoPCMData:(NSData *)data withSampleRate:(int)sampleRate andBitsPerChannel:(int)bitRate toFileLocation:(NSString *)fileLocation;
/**Writes out a Speex file from an array of Speex dictionaries*/
- (NSError *) writeSpeexFileFromArrayOfSpeexDictionaries:(NSArray *)speexArray inSpeexMode:(NSString *)speexMode toFileLocation:(NSString *)fileLocation;


@end
