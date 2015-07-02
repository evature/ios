
#import <AudioToolbox/AudioToolbox.h>
#import <FLAC/all.h>

#define NUMBER_AUDIO_DATA_BUFFERS  3

/*
 * The delegate does the actual drawing.
 */
@protocol RecorderDelegate <NSObject>
@required
- (void)recordedFreq:(float)freq;
@end

/*
 * Records from the microphone.
 */
@interface Recorder : NSObject
{
	// our delegate object
	id <RecorderDelegate> delegate;
	
	// whether we're currently recording
	BOOL recording;

	// whether we're currently doing the FFT pitch tracking
	BOOL trackingPitch;

	// the format used for recording
	AudioStreamBasicDescription audioFormat;

	// the audio queue object being used for recording
	AudioQueueRef recordQueue;
	
	// the audio queue buffers for the recording audio queue
	AudioQueueBufferRef recordQueueBuffers[NUMBER_AUDIO_DATA_BUFFERS];

	// the number of bytes to use in each audio queue buffer
	UInt32 bufferByteSize;

	// the number of audio data packets to read into each audio queue buffer
	UInt32 bufferNumPackets;
    
    FLAC__StreamEncoder *_encoder;
    int  _frameIndex;
}

@property (nonatomic, assign) id <RecorderDelegate> delegate;

@property (assign) BOOL recording;
@property (assign) BOOL trackingPitch;
@property (assign) AudioQueueRef recordQueue;
@property (assign) UInt32 bufferByteSize;
@property (assign) UInt32 bufferNumPackets;

- (void)startRecording;
- (void)stopRecording;
- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize;

@end
