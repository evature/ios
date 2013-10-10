
#import "Recorder.h"
//#include "fft.h"

#define READSIZE 1024*4//1024
#define CHANNELS 1
#define SAMPLE_RATE 16000.0
#define RECORD_MAX_LENGTH 10 // in seconds

#define SAVE_TO_FILE TRUE//FALSE

static FLAC__int32 pcm[READSIZE/*samples*/ * CHANNELS/*channels*/];

@interface Recorder (Private)
- (void)setUpAudioFormat;
- (UInt32)numPacketsForTime:(Float64)seconds;
- (UInt32)byteSizeForNumPackets:(UInt32)numPackets;
- (void)primeRecordQueueBuffers;
- (void)setUpRecordQueue;
- (void)setUpRecordQueueBuffers;
@end

@implementation Recorder
@synthesize delegate = _delegate;
//@synthesize delegate;
@synthesize recording,shouldStopRecording,finishCleaning;
@synthesize trackingPitch;
@synthesize recordQueue;
@synthesize bufferByteSize;
@synthesize bufferNumPackets;


@synthesize savedPath = _savedPath;

@synthesize _frameIndex;


+ (Recorder *)sharedInstance
{
    static Recorder *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[Recorder alloc] init];
	}
	return sharedInstance;
}

-(void)sendRecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
    NSLog(@"sendRecorderMicLevelCallbackAverage");
    
    if([_delegate respondsToSelector:@selector(recorderMicLevelCallbackAverage:andPeak:)]){
        
        [_delegate recorderMicLevelCallbackAverage:averagePower andPeak:peakPower];

    }else{
        NSLog(@"Error: You haven't implemented recorderMicLevelCallbackAverage, It is a must. Please implement this one");
    }
    
}

-(float)averagePower {
    float channelAvg = 0;
    //float channelPeak = 0;
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * CHANNELS;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
    OSStatus rc = AudioQueueGetProperty(recordQueue, kAudioQueueProperty_CurrentLevelMeterDB//kAudioQueueProperty_CurrentLevelMeter
                                        , levels, &dataSize);
    
    //NSLog(@"levels->mAveragePower: %f", levels->mAveragePower);
    
    if (rc) {
        NSLog(@"AudioQueueGetProperty(CurrentLevelMeter) returned %ld", rc);
        free(levels);
        return 0;
    } else {
        //  NSLog(@"Status success of level meter");
        
        
     /*   for (int i = 0; i < CHANNELS; i++) {
            NSInteger channelIdx = levels[i].mPeakPower;
            if (channelIdx > 127) {
                
            }else{
                channelAvg += levels[i].mPeakPower;
                //levels->mAveragePower;
            }
        }*/
        channelAvg = levels->mAveragePower;
        
        
    }
    free(levels);
    
    // This works because in this particular case one channel always has an mAveragePower of 0.
    //return channelAvg;
    return channelAvg;
}

-(float)peakPower {
   // float channelAvg = 0;
    float channelPeak = -150; //0;
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * CHANNELS;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
    OSStatus rc = AudioQueueGetProperty(recordQueue, kAudioQueueProperty_CurrentLevelMeterDB//kAudioQueueProperty_CurrentLevelMeter
                                        , levels, &dataSize);
    
    //NSLog(@"levels->mAveragePower: %f", levels->mAveragePower);
    
    if (rc) {
        NSLog(@"AudioQueueGetProperty(CurrentLevelMeter) returned %ld", rc);
        free(levels);
        return channelPeak;
    } else {
        //  NSLog(@"Status success of level meter");
  /*
        
        for (int i = 0; i < CHANNELS; i++) {
            if (channelPeak < levels[i].mPeakPower) {
                channelPeak = levels[i].mPeakPower;
            }
   
        }*/
        channelPeak=levels->mPeakPower;
    }
    free(levels);
    // This works because in this particular case one channel always has an mAveragePower of 0.
    //return channelPeak;
    return channelPeak;
}


static void recordCallback(
	void* inUserData,
	AudioQueueRef inAudioQueue,
	AudioQueueBufferRef inBuffer,
	const AudioTimeStamp* inStartTime,
	UInt32 inNumPackets,
	const AudioStreamPacketDescription* inPacketDesc)
{
    NSLog(@"recordCallback %u", (unsigned int)inBuffer->mAudioDataByteSize);
    
   
	Recorder* recorder = (Recorder*) inUserData;
	if (!recorder.recording)
		return;
    
	if (inNumPackets > 0)
    {
		[recorder recordedBuffer:inBuffer->mAudioData byteSize:inBuffer->mAudioDataByteSize packetsNum:inNumPackets];
    }

    AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
    
    

    
    
    
    // This works because one channel always has an mAveragePower of 0.
    // channelAvg;
    
   // [recorder_ averagePowerForChannel:0] andPeak:[recorder_ peakPowerForChannel:0]];
}

/*-(NSString *)recFlacFileString{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES)[0];
//[NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
    NSString *tmpFileUrl = [docsDir stringByAppendingPathComponent:@"rec.flac" //@"rec.m4a"//m4a"
                                                ];
    return tmpFileUrl;
    
    
}*/


- (id)init
{
	if ((self = [super init]))
	{
		recording = NO;
        finishCleaning = YES;
		[self setUpAudioFormat];
        recordQueue = nil;
		//[self setUpRecordQueue];
		//[self setUpRecordQueueBuffers];
        
        
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES)[0];
        //NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *savePath = [documentDir stringByAppendingPathComponent:@"rec.flac"];
        
        [_savedPath release];
        _savedPath = [savePath copy];
	}
	return self;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = SAMPLE_RATE;//16000.0;
	audioFormat.mChannelsPerFrame = CHANNELS;//1;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16); 
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger 
	                              | kLinearPCMFormatFlagIsPacked;

	bufferNumPackets = 2048;  // must be power of 2 for FFT!
	bufferByteSize = [self byteSizeForNumPackets:bufferNumPackets];

	
	
	//init_fft(bufferNumPackets, audioFormat.mSampleRate);
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
    
    UInt32 trueValue = true;
    AudioQueueSetProperty(recordQueue,kAudioQueueProperty_EnableLevelMetering,&trueValue,sizeof (UInt32));
}

- (void)setUpRecordQueueBuffers
{
    assert(recordQueue != nil);
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
    assert(recordQueue != nil);
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
    NSLog(@"Starting to record");
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (!finishCleaning) {
            // waiting
        }*/
        recording = YES;
        shouldStopRecording = NO;
//        if (recordQueue != nil) {
//            AudioQueueDispose(recordQueue, true);
//        }
//       [self setUpRecordQueue]; //  IFTAH
//       [self setUpRecordQueueBuffers]; // IFTAH
    
//    if (recordQueue != nil)
//        AudioQueueStop(recordQueue, TRUE);
    _frameIndex= 0;
    self.fileWasCreated = NO;
    [self setUpRecordQueue];
    [self setUpRecordQueueBuffers];
    [self primeRecordQueueBuffers];
//                   
    
                   //AudioQueueReset(recordQueue); // NEW
        AudioQueueStart(recordQueue, NULL);
        
        
   // });
    
    
   /*
	recording = YES;
    shouldStopRecording = NO;
    //[self setUpRecordQueue]; // NEW
    //[self setUpRecordQueueBuffers]; // NEW
	[self primeRecordQueueBuffers];  // Commented for test
    
    
    //AudioQueueReset(recordQueue); // NEW
	AudioQueueStart(recordQueue, NULL);*/
    
}

- (void)stopRecording
{
    // Iftah
    if (_encoder!=nil) {
        FLAC__stream_encoder_finish(_encoder);
    }
    /*if (_encoder!=nil) {
        FLAC__stream_encoder_finish(_encoder);
        FLAC__stream_encoder_delete(_encoder);
    }*/
    
    NSLog(@"Stoping to record");
 
	AudioQueueStop(recordQueue, FALSE);
    recordQueue = nil;
    
     NSLog(@"Stopped recording");
    
    //[self performSelector:@selector(cleanTheRecorder) withObject:[NSNull null] afterDelay:3.0];
	//recording = NO;
    shouldStopRecording = YES;
    recording = NO; // Iftah;
    //[self cleanTheRecorder]; // NEW COMMENTED 4/9/13
    
  /*  if([_delegate respondsToSelector:@selector(soundRecoderDidFinishRecording:)]){

        [_delegate soundRecoderDidFinishRecording:self];
    }*/
    
    //AudioQueueDispose(recordQueue, true);//FALSE);  // NEW
}

-(void)cleanTheRecorder{
    
   /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (recording) {
            // waiting
        }
     */   
        
        if (!recording) {
            if (_encoder!=nil) {
                FLAC__stream_encoder_finish(_encoder);
                FLAC__stream_encoder_delete(_encoder);
                _encoder = nil; // NEW - 4/9/13
            }
            recording = NO;
            
        }
        if([_delegate respondsToSelector:@selector(soundRecoderDidFinishRecording:)]){
            
            [_delegate soundRecoderDidFinishRecording:self];
        }
        finishCleaning = TRUE;
        self.fileWasCreated = NO;
        
  //  });
    
    
    
    
    
    
    
}

// called from encoder
void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data){
    
    NSLog(@"bytes_written = %lld, frames_written = %d, total_frames_estimate=%d", bytes_written, frames_written,total_frames_estimate);
    
    Recorder *userRecoreder =(Recorder*)client_data;
    
    NSLog(@"userRecoreder._frameIndex = %d", userRecoreder._frameIndex);
    
    if (userRecoreder._frameIndex -1 <= frames_written && userRecoreder.shouldStopRecording) {
        userRecoreder.recording = NO;
        //[userRecoreder cleanTheRecorder];
        //[userRecoreder stopRecording];
    }
    
    return ;
}


FLAC__StreamEncoderWriteStatus send_music(const FLAC__StreamEncoder *encoder, const FLAC__byte buffer[], size_t bytes, unsigned samples, unsigned current_frame, void *client_data)
{
	//when music is encoded, send it over the wire
    // Check if respond to selector.... //
    [[(Recorder*)client_data delegate] dataSend:(void*)buffer withLength:bytes ];
    
	//if(!datasend((void *)buffer, bytes))
    //    return FLAC__STREAM_ENCODER_WRITE_STATUS_FATAL_ERROR;
	return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize packetsNum:(unsigned int)inNumPackets
{
    unsigned sample_rate = SAMPLE_RATE;
	unsigned channels = CHANNELS;//1;
	unsigned bps = 16;
    FLAC__bool ok = true;
    
    if (_frameIndex ++== 0)
    {
        
        
		_encoder = FLAC__stream_encoder_new();
		FLAC__stream_encoder_set_verify(_encoder,true);
		FLAC__stream_encoder_set_compression_level(_encoder, 5);
		FLAC__stream_encoder_set_channels(_encoder, channels);
		FLAC__stream_encoder_set_bits_per_sample(_encoder, bps);
		FLAC__stream_encoder_set_sample_rate(_encoder, sample_rate);
		FLAC__stream_encoder_set_total_samples_estimate(_encoder, sample_rate * RECORD_MAX_LENGTH);
		FLAC__StreamEncoderInitStatus init_status;
        
        //NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        //NSString *savePath = [documentDir stringByAppendingPathComponent:@"rec.flac"];
#if SAVE_TO_FILE
		//init_status = FLAC__stream_encoder_init_file(_encoder, [_savedPath UTF8String], NULL, NULL);
        
        init_status = FLAC__stream_encoder_init_file(_encoder, [_savedPath UTF8String], progress_callback, self);
#else
        init_status = FLAC__stream_encoder_init_stream(_encoder,send_music,NULL,NULL,NULL,self);
#endif
        
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
        NSLog(@"need = %ld",need);
        if (_encoder!=nil) {
            ok = FLAC__stream_encoder_process_interleaved(_encoder, pcm, need);
             
        }else{
            return;
        }
        
        
        left -= need;
        
        NSLog(@"------ frame index - %d", _frameIndex);

        if ([_delegate respondsToSelector:@selector(recordFileWasCreated)]) {
            NSLog(@"respondsToSelector:@selector(recordFileWasCreated)");
        }else{
            NSLog(@"Error with respondsToSelector:@selector(recordFileWasCreated)");
        }
        
        if (!self.fileWasCreated && [_delegate respondsToSelector:@selector(recordFileWasCreated)])
        {
            NSLog(@"------ fileWasCreated -----");
            [_delegate recordFileWasCreated];
            self.fileWasCreated = YES;
        }
    }
}

-(void)cleanRecorder{
    AudioQueueDispose (recordQueue, YES);
    
    [self cleanTheRecorder];
    [super dealloc];
    
}
- (void)dealloc
{
    
    NSLog(@"+++++ Record - Dealloc was called ++++++");
	//done_fft();
	//AudioQueueDispose(recordQueue, YES);
    
    // below new
    //AudioQueueReset (recordQueue);
    //AudioQueueStop (recordQueue, YES);
    AudioQueueDispose (recordQueue, YES);
    
    [self cleanTheRecorder];
    
	[super dealloc];
}

@end
