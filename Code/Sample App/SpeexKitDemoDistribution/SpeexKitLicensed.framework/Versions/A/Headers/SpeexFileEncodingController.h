//
//  SpeexFileEncodingController.h
//  SpeexKit
//
//  Created by Halle Winkler on 1/6/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 @class  SpeexFileEncodingController
 @brief  A class that encodes complete WAV or raw audio files into complete Speex files.
 */

@interface SpeexFileEncodingController : NSObject {
/** options are "Narrowband", "Wideband" and "UltraWideband". For 8-bit use Narrowband, for 16-bit use Wideband, for more use UltraWideBand. This is necessary to set.*/
    NSString *mode; 
    /** options are 0-10, default is 8. Not necessary to set.*/
    int quality; 
    /** The maximum bitrate to use. Not necessary to set.*/
    int bitrate; 
    /** Use VBR encoding. Optional.*/
    BOOL variableBitrate; 
    /** maximum bitrate for vbr. Optional.*/
    int vbrBitrate;
    /** If set to a number, enable average bitrate at the described rate, defaults to -1. Optional.*/
    int averageBitRate; 
    /** Use voice activity detection, defaults to NO, optional.*/
    BOOL vad;
    /** File-based discontinuous transmission, defaults to NO, optional.*/
    BOOL dtx; 
    /** encoding complexity from 0-10, default is 3, not necessary to set.*/
    int complexity; 
    /** If TRUE, denoise input first. Defaults to FALSE. Optional.*/
    BOOL denoiseInput; 
    /** Turn on AGC. Optional.*/
    BOOL useAGC; 
    /** Verbose mode, reports used bitrates, defaults to FALSE, optional.*/
    BOOL verbose; 
    /** Quiet mode, suppresses all output, defaults to FALSE, optional.*/
    BOOL verboseSpeexKit; 
    /** Sample rate for input, not necessary to set unless the encoder has some problem detecting this.*/
    int sampleRate;
    /** Force input to be considered stereo, not necessary to set unless the encoder has some problem detecting this.*/
    BOOL inputIsStereo; 
    /** Endianness of input, options are "LE" and "BE", not necessary to set unless the encoder has some problem detecting this. Unlikely to be needed for an iOS implementation.*/
    NSString *endianness; 
    /** Defaults to -1 which lets the encoder decide. If set to 8, input is taken as 8-bit, if set to 16, input is taken as 16-bit. Not necessary to set unless the decoder has some problem detecting this.*/
    int inputBits; 
    /** Set this to TRUE to get a timing for your conversion. Useful for discovering how to optimize your operation on the device using the different encoding options available.*/
    BOOL timeConversion; 

}
/** This takes one entire file and converts it to a spx with a header.*/
- (void) encodeLocalRawOrWavFileAtPath:(NSString *)localFile intoSpeexFileAtPath:(NSString *)speexFile; 


@property (nonatomic, copy) NSString *mode; // options are "Narrowband", "Wideband" and "UltraWideband".
@property (nonatomic, assign) int quality; // options are 0-10, default is 8.
@property (nonatomic, assign) int bitrate; // The maximum bitrate to use.
@property (nonatomic, assign) BOOL variableBitrate; // Use VBR encoding.
@property (nonatomic, assign) int vbrBitrate; // maximum bitrate for vbr.
@property (nonatomic, assign) int averageBitRate; // If set to a number, enable average bitrate at the described rate, defaults to -1.
@property (nonatomic, assign) BOOL vad; // Use voice activity detection, defaults to NO.
@property (nonatomic, assign) BOOL dtx; // File-based discontinuous transmission, defaults to NO.
@property (nonatomic, assign) int complexity; // encoding complexity from 0-10, default is 3.
@property (nonatomic, assign) int framesPerOggPacket; // Number of frames per Ogg packet between 1-10.
@property (nonatomic, assign) BOOL denoiseInput; // If TRUE, denoise input first. Defaults to FALSE.
@property (nonatomic, assign) BOOL useAGC; // Turn on AGC.
@property (nonatomic, assign) BOOL verbose; // Verbose mode, defaults to FALSE.
@property (nonatomic, assign) BOOL verboseSpeexKit; // Quiet mode, suppresses all output, defaults to FALSE.
@property (nonatomic, assign) int sampleRate; // Sample rate for input
@property (nonatomic, assign) BOOL inputIsStereo; // Force input to be considered stereo
@property (nonatomic, copy) NSString *endianness; // Endianness of input, options are "LE" and "BE".
@property (nonatomic, assign) int inputBits; // Defaults to -1. If set to 8, input is taken as 8-bit, if set to 16, input is taken as 16-bit.
@property (nonatomic, assign) BOOL timeConversion; // Set this to TRUE to get a timing for your conversion.


@end


