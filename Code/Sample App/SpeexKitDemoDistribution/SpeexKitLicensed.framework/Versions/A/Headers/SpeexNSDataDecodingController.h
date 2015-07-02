//
//  SpeexNSDataDecodingController.h
//  SpeexKit
//
//  Created by Halle Winkler on 2/18/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "speex.h"

@class SpeexDecoder;

@protocol SpeexNSDataDecodingControllerDelegate;

/**
 @class  SpeexNSDataDecodingController
 @brief  A class that decodes buffers of Speex into buffers of PCM.
 */

@interface SpeexNSDataDecodingController : NSObject{
    
    void *speexState;
    SpeexBits speexBits;
    NSString *mode;
    BOOL optionsWereSet;
    int frameSize;
    
    
    id<SpeexNSDataDecodingControllerDelegate> delegate;
    
    NSThread *speexDecodingThread;
    NSMutableArray *localQueue;
/**Toggle verbosity to get logging output */    
    BOOL verboseSpeexKit;

}

@property(nonatomic, copy) NSString *mode;
@property(nonatomic, assign) BOOL optionsWereSet;
@property(nonatomic, assign) int frameSize;
@property (nonatomic, retain) NSThread *speexDecodingThread;
@property (nonatomic, retain) NSMutableArray *localQueue;

/**Toggle verbosity to get logging output */
@property(nonatomic, assign) BOOL verboseSpeexKit;

@property (assign) id<SpeexNSDataDecodingControllerDelegate> delegate;

- (NSData *)decodeSpeexNSData:(NSData*)speexData withSpeexFrameSize:(int)speexFrameSize; // set int decodedFrames = 0 before calling this and you can read the number of frames from it after the method is complete.
- (void) setSpeexDecodingOptions;
- (void) asynchronouslyDecodeSpeexNSData:(NSData*)speexData withSpeexFrameSize:(int)speexFrameSize;

@end
/**
 @protocol  SpeexNSDataDecodingControllerDelegate
 @brief  Delegate methods of SpeexNSDataDecodingController that deliver results to you asynchronously.
 

 
 */

@protocol SpeexNSDataDecodingControllerDelegate <NSObject>
@optional 
/**Callback method that you can receive if you set a delegate for this class that informs you when a speex buffer has been decoded and delivers it */
- (void) asynchronousDecoderCreatedPCMData:(NSData *)pcmData;

@end
