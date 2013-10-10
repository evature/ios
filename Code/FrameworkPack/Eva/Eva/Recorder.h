
#import <AudioToolbox/AudioToolbox.h>
#import <FLAC/all.h>

#define NUMBER_AUDIO_DATA_BUFFERS  3//3

@class Recorder;
/*
 * The delegate does the actual drawing.
 */

@protocol RecorderDelegate <NSObject>
@optional
//@required
//- (void)recordedFreq:(float)freq;
-(void)soundRecoderDidFinishRecording:(Recorder*)recoder;
-(void)dataSend:(void*)data withLength: (unsigned) len;

- (void)recordFileWasCreated;

- (void)recorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;

-(void)recorderIsReady;
@end

/*
 * Records from the microphone.
 */
@interface Recorder : NSObject
{
	// our delegate object
	//id <RecorderDelegate> delegate;
	
	// whether we're currently recording
	BOOL recording, shouldStopRecording,finishCleaning;
    
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
    
    NSString *savedPath;
    
    BOOL isRecorderReady;
    
    
    
    
}

@property (nonatomic,
           assign
           
           ) id <RecorderDelegate> delegate;

@property (assign,atomic) BOOL recording,shouldStopRecording,finishCleaning;
@property (assign) BOOL trackingPitch;
@property (assign) AudioQueueRef recordQueue;
@property (assign) UInt32 bufferByteSize;
@property (assign) UInt32 bufferNumPackets;
@property(nonatomic, assign) BOOL fileWasCreated;
@property(nonatomic, assign)  BOOL isRecorderReady;

@property (nonatomic,copy) NSString *savedPath;

@property (assign) int _frameIndex;

+ (Recorder *)sharedInstance;

- (void)startRecording;
- (void)startRecording:(BOOL) autoStop;
- (void)stopRecording;
-(void)cleanRecorder;

-(float)averagePower;
-(float)peakPower;

-(BOOL)isRecorderReady;

//- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize;

@end
