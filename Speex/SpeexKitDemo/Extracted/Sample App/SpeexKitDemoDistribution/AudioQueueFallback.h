//  OpenEars version 1.0
//  http://www.politepix.com/openears
//
//  AudioQueueFallback.h
//  OpenEars

#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR

#ifndef _AD_H_
#define _AD_H_

#import <AudioToolbox/AudioToolbox.h> 

#define kNumberOfChunksInRingbufferAudioQueue 28
#define kChunkSizeInBytesAudioQueue 16192 * 3

typedef SInt16 int16;
typedef UInt32 int32;

typedef struct { // The audio device struct used by Pocketsphinx.
	AudioQueueRef audioQueue; // The Audio Queue.
	AudioQueueBufferRef audioQueueBuffers[3]; // The buffer array of the Audio Queue, 3 buffers is standard for Core Audio. 
	CFStringRef currentRoute; // The current Audio Route for the device (e.g. headphone mic or external mic).
	AudioStreamBasicDescription audioQueueRecordFormat; // The recording format of the Audio Queue. 

	BOOL audioQueueIsRunning; // Is the queue instantiated? 
	BOOL recording; // Is the Audio Queue currently recording sound? 
	SInt32 sps;		// Samples per second.
	SInt32 bps;		// Bytes per sample.

    	int callbacks;
} pocketsphinxAudioDevice;	

@protocol ContinuousAudioUnitDelegate;

@interface ContinuousAudioUnit : NSObject  {
    __unsafe_unretained id<ContinuousAudioUnitDelegate> delegate;
}

@property (assign) id<ContinuousAudioUnitDelegate> delegate;


pocketsphinxAudioDevice *openAudioDevice (const char *audioDevice, SInt32 samplesPerSecond); // Function to open the "audio device" or in this case instantiate a new Audio Queue.

SInt32 startRecording(pocketsphinxAudioDevice * audioDevice); // Tell the Audio Queue to start recording.
SInt32 stopRecording(pocketsphinxAudioDevice * audioDevice); // Tell the Audio Queue to stop recording.
SInt32 closeAudioDevice(pocketsphinxAudioDevice * audioDevice); // Close the "audio device" or in this case stop and free the Audio Queue.
void AudioQueueInputBufferCallback(void *inUserData,
								   AudioQueueRef inAudioQueue,
								   AudioQueueBufferRef inBuffer,
								   const AudioTimeStamp *inStartTime,
								   UInt32 inNumberOfPackets,
								   const AudioStreamPacketDescription *inPacketDescription);

- (id) initWithDelegate:(id)initdelegate;

@end

@protocol ContinuousAudioUnitDelegate <NSObject>
@optional 

- (void) samplesAvailable:(SInt16 *)samples withNumberOfSamples:(int)numberOfSamples;

@end

#endif
#else
#endif