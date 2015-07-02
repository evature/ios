
#import "Recorder.h"
#include "fft.h"

#define READSIZE 1024

static FLAC__int32 pcm[READSIZE/*samples*/ * 1/*channels*/];

@interface Recorder (Private)
- (void)setUpAudioFormat;
- (UInt32)numPacketsForTime:(Float64)seconds;
- (UInt32)byteSizeForNumPackets:(UInt32)numPackets;
- (void)primeRecordQueueBuffers;
- (void)setUpRecordQueue;
- (void)setUpRecordQueueBuffers;
@end

@implementation Recorder

@synthesize delegate;
@synthesize recording;
@synthesize trackingPitch;
@synthesize recordQueue;
@synthesize bufferByteSize;
@synthesize bufferNumPackets;

static void recordCallback(
	void* inUserData,
	AudioQueueRef inAudioQueue,
	AudioQueueBufferRef inBuffer,
	const AudioTimeStamp* inStartTime,
	UInt32 inNumPackets,
	const AudioStreamPacketDescription* inPacketDesc)
{
	Recorder* recorder = (Recorder*) inUserData;
	if (!recorder.recording)
		return;
    
	if (inNumPackets > 0)
    {
		[recorder recordedBuffer:inBuffer->mAudioData byteSize:inBuffer->mAudioDataByteSize packetsNum:inNumPackets];
    }

	AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
}

- (id)init
{
	if ((self = [super init]))
	{
		recording = NO;
		[self setUpAudioFormat];
		[self setUpRecordQueue];
		[self setUpRecordQueueBuffers];
	}
	return self;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = 16000.0;
	audioFormat.mChannelsPerFrame = 1;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16); 
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger 
	                              | kLinearPCMFormatFlagIsPacked;

	bufferNumPackets = 2048;  // must be power of 2 for FFT!
	bufferByteSize = [self byteSizeForNumPackets:bufferNumPackets];

	//NSLog(@"Recorder bufferNumPackets %u", bufferNumPackets);
	//NSLog(@"Recorder bufferByteSize %u", bufferByteSize);
	
	init_fft(bufferNumPackets, audioFormat.mSampleRate);
}

- (UInt32)numPacketsForTime:(Float64)seconds
{
	return (UInt32) (seconds * audioFormat.mSampleRate / audioFormat.mFramesPerPacket);
}

- (UInt32)byteSizeForNumPackets:(UInt32)numPackets
{
	return numPackets * audioFormat.mBytesPerPacket;
}

- (void)setUpRecordQueue
{
	AudioQueueNewInput(
		&audioFormat,
		recordCallback,
		self,                // userData
		CFRunLoopGetMain(),  // run loop
		NULL,                // run loop mode
		0,                   // flags
		&recordQueue);
}

- (void)setUpRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueAllocateBuffer(
			recordQueue,
			bufferByteSize,
			&recordQueueBuffers[t]);
	}
}

- (void)primeRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueEnqueueBuffer(
			recordQueue,
			recordQueueBuffers[t],
			0,
			NULL);
	}
}

- (void)startRecording
{
	recording = YES;
	[self primeRecordQueueBuffers];
    
	AudioQueueStart(recordQueue, NULL);
}

- (void)stopRecording
{
    
    FLAC__stream_encoder_finish(_encoder);
	FLAC__stream_encoder_delete(_encoder);
    
	AudioQueueStop(recordQueue, TRUE);
	recording = NO;
}

- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize packetsNum:(unsigned int)inNumPackets
{
    unsigned sample_rate = 16000;
	unsigned channels = 1;
	unsigned bps = 16;
    FLAC__bool ok = true;
    
    if (_frameIndex ++== 0)
    {
		_encoder = FLAC__stream_encoder_new();
		FLAC__stream_encoder_set_verify(_encoder,true);
		FLAC__stream_encoder_set_compression_level(_encoder, 5);
		FLAC__stream_encoder_set_channels(_encoder, channels);
		FLAC__stream_encoder_set_bits_per_sample(_encoder, bps);
		FLAC__stream_encoder_set_sample_rate(_encoder, 16000);
		FLAC__stream_encoder_set_total_samples_estimate(_encoder, sample_rate * 10);
		FLAC__StreamEncoderInitStatus init_status;
        
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *savePath = [documentDir stringByAppendingPathComponent:@"test.flac"];
        
		init_status = FLAC__stream_encoder_init_file(_encoder, [savePath UTF8String], NULL, NULL);
		if (init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK )
        {
			NSLog(@"FLAC: Failed to initialize encoder: %s", FLAC__StreamEncoderInitStatusString[init_status]);
			FLAC__stream_encoder_delete(_encoder);
			_encoder = NULL;
			return;
		}
	}
    
    size_t left = (size_t)inNumPackets;
    while(ok && left)
    {
        size_t need = (left > READSIZE ? (size_t)READSIZE : (size_t)left);
        
        size_t i;
        for(i = 0; i < need * channels; i++)
        {
            /* inefficient but simple and works on big- or little-endian machines */
            pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)buffer[2 * i + 1] << 8) | (FLAC__int16)buffer[2 * i]);
        }
        
        /* feed samples to encoder */
        ok = FLAC__stream_encoder_process_interleaved(_encoder, pcm, need);
        
        left -= need;
    }
}

- (void)dealloc
{
	done_fft();
	AudioQueueDispose(recordQueue, YES);
	[super dealloc];
}

@end
