//
//  SpeexNSDataEncodingController.h
//  SpeexKit
//
//  Created by Halle Winkler on 2/18/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//


#import "speex.h"
#import "speex_preprocess.h"

@protocol SpeexNSDataEncodingControllerDelegate;

/**
 @class  SpeexNSDataEncodingController
 @brief  A class that encodes buffers of PCM into buffers of Speex.
 */

@interface SpeexNSDataEncodingController : NSObject {
    NSString *mode;
    void *speexState;
    SpeexBits speexBits;
    SpeexPreprocessState *preprocessState;
    int frameSize;
    /**Toggle the Speex denoise property*/
    BOOL denoise;
    /**Toggle the Speex dereverb property*/    
    BOOL dereverb;
    /** options are 0-10, default is 8. Not necessary to set.*/

    int quality;
    /** Toggle speex vbr option*/
    BOOL variableBitrate;
    /** maximum bitrate for vbr. Optional.*/
    int vbrBitrate;
    /** If set to a number, enable average bitrate at the described rate, defaults to -1. Optional.*/

    int averageBitRate;
    /** Use voice activity detection, defaults to NO, optional.*/

    BOOL vad;
    /** encoding complexity from 0-10, default is 3, not necessary to set.*/

    int complexity;
    
    /**1-10 quality level for speex vbr if it is set to on */
    int vbrQuality;
    /** Sample rate for input, not necessary to set unless the encoder has some problem detecting this.*/

    int sampleRate;
    /**Toggle verbosity for logging output*/
    BOOL verboseSpeexKit;
    /**If set to true with logging on, time used to encode buffer will be output to logging*/
    BOOL timeEncoding;
    
    
    int lookAhead;
    NSMutableArray *localQueueMutable;
    
    id<SpeexNSDataEncodingControllerDelegate> delegate;

    NSThread *speexEncodingThread;
    NSData *extraSamples;
}


- (void) setSpeexEncodingOptions;
- (NSArray *) convertNSDataToSpeex:(NSData*)data;
- (void) asynchronouslyConvertNSDataToSpeex:(NSData*)data;

@property(nonatomic,retain) NSString *mode;
@property(nonatomic,assign) int frameSize;
@property(nonatomic,assign) BOOL denoise;
@property(nonatomic,assign) BOOL dereverb;
@property(nonatomic,assign) int quality;
@property(nonatomic,assign) BOOL variableBitrate;
@property(nonatomic,assign) int vbrBitrate;
@property(nonatomic,assign) int averageBitRate;
@property(nonatomic,assign) BOOL vad;
@property(nonatomic,assign) int complexity;
@property(nonatomic,assign) int vbrQuality;
@property(nonatomic,assign) BOOL verboseSpeexKit;
@property(nonatomic,assign) int sampleRate;
@property (nonatomic, retain) NSMutableArray *localQueueMutable;
@property(nonatomic,assign) BOOL timeEncoding;
@property(nonatomic,assign) int lookAhead;
@property (nonatomic, retain) NSThread *speexEncodingThread;
@property (assign) id<SpeexNSDataEncodingControllerDelegate> delegate;
@property (nonatomic, retain) NSData *extraSamples;


@end

/**
 @protocol  SpeexNSDataEncodingControllerDelegate
 @brief  Delegate methods of SpeexNSDataEncodingController that deliver results to you asynchronously.
 
 
 
 */

@protocol SpeexNSDataEncodingControllerDelegate <NSObject>

@optional 
/**Callback method that you can receive if you set a delegate for this class that informs you when a PCM buffer has been encoded and delivers it */
- (void) asynchronousEncoderCreatedSpeexArray:(NSArray *)speexArray;

@end
