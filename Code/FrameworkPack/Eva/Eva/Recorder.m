
#import "Recorder.h"
//#include "fft.h"


#define DEBUG_RECORDER FALSE

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
@synthesize isRecorderReady=_isRecorderReady;


+ (Recorder *)sharedInstance
{
    static Recorder *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[Recorder alloc] init];
        sharedInstance.isRecorderReady = FALSE;
        //isRecorderReady = FALSE;
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

-(BOOL)isRecorderReady{
    return isRecorderReady;
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
    
    
	Recorder* recorder = (__bridge Recorder*) inUserData;
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
        
        
        // Below new for iOS 7 issue //
        //NSString *osVersion = [[UIDevice currentDevice]  systemVersion];
        
        //if ([osVersion doubleValue]>=6){
            AudioSessionInitialize(
                               NULL,
                               NULL,
                               nil,
                               (__bridge  void *)(self)
                               );
        
            UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
            AudioSessionSetProperty(
                                kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory
                                );
        
            AudioSessionSetActive(true);
       // }
        ////////////////////////////////////
        
		[self setUpAudioFormat];
        recordQueue = nil;
		//[self setUpRecordQueue];
		//[self setUpRecordQueueBuffers];
        
       // NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent: (NSString*)@"rec.flac"];
        
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                                    , NSUserDomainMask,YES)[0];
        //NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *savePath = [documentDir stringByAppendingPathComponent:@"rec.flac"];//[NSTemporaryDirectory() stringByAppendingPathComponent:@"rec.flac"];//[documentDir stringByAppendingPathComponent:@"rec.flac"];
        
        NSLog(@"\n\nsavePath = %@\n\n",savePath);
        
        
        
        
       // [_savedPath release];
        _savedPath = [savePath copy];//[savePath copy];
        
        
	}
	return self;
}


static char *FormatError(char *str, OSStatus error)
{
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    return str;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = SAMPLE_RATE;//16000.0;
	audioFormat.mChannelsPerFrame = CHANNELS;//1;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16);
    //audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame; // NEW for iOS 7 issue fix
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
    
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
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

//- (void)setUpRecordQueue
- (void)setUpRecordQueue
{
    NSLog(@"\n+++ setUpRecordQueue");
	OSStatus errorStatus = AudioQueueNewInput(
                       &audioFormat,
                       recordCallback,
                       (__bridge void *)(self),                // userData
                       CFRunLoopGetMain(),  // run loop
                       NULL,                // run loop mode
                       0,                   // flags
                       &recordQueue);
    
    if (errorStatus) {
        NSLog(@"\n\n ERROR : Error %ld on AudioQueueNewInput\n", errorStatus );
    }
    
    
    if (recordQueue == nil) {
        NSLog(@"\n\n ----- Record Queue is nil! -----");
       // return FALSE;
        return;
    }
    
    UInt32 trueValue = true;
    AudioQueueSetProperty(recordQueue,kAudioQueueProperty_EnableLevelMetering,&trueValue,sizeof (UInt32));
    //return TRUE;
}

//- (void)setUpRecordQueueBuffers
- (void)setUpRecordQueueBuffers
{
    NSLog(@"\n+++ setUpRecordQueueBuffers");
    //assert(recordQueue != nil);
    if (recordQueue == nil) { // New instead of Assert.
        return;
        //return FALSE;
    }
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		OSStatus errorStatus = AudioQueueAllocateBuffer(
                                 recordQueue,
                                 bufferByteSize,
                                 &recordQueueBuffers[t]);
        if (errorStatus) {
            NSLog(@"\n\n ERROR : Error %ld on AudioQueueAllocateBuffer\n", errorStatus );
        }
	}
    //return TRUE;
}

//- (void)primeRecordQueueBuffers
- (void)primeRecordQueueBuffers
{
    NSLog(@"\n+++ primeRecordQueueBuffers");
    //assert(recordQueue != nil);
    if (recordQueue == nil) { // New instead of Assert
       // return FALSE;
        return;
    }
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		OSStatus errorStatus = AudioQueueEnqueueBuffer(
                                recordQueue,
                                recordQueueBuffers[t],
                                0,
                                NULL);
        if (errorStatus) {
            NSLog(@"\n\n ERROR : Error %ld on AudioQueueEnqueueBuffer\n", errorStatus );
        }
	}
    //return TRUE;
}

- (void)startRecording
{
    [self startRecording:FALSE];
}

- (void)startRecording:(BOOL) autoStop
{
    
    if (autoStop) { // New because when second initiation could be that this one won't be ready...
        isRecorderReady = FALSE;
        NSLog(@"Starting to record with autoStop!");
    }else{
        NSLog(@"Starting to record no autoStop");
    }
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
        NSLog(@"PPPP C1");
        _frameIndex= 0;
        //BOOL isFailed = FALSE;
        self.fileWasCreated = NO;
        [self setUpRecordQueue];// NEED to check if return TRUE //
           
        NSLog(@"PPPP C2");
       [self setUpRecordQueueBuffers];
          
        
        NSLog(@"PPPP C3");
        [self primeRecordQueueBuffers] ;
        NSLog(@"PPPP C4");
        //
        //AudioQueueReset(recordQueue); // NEW
                       
       /* UInt32 size = sizeof(audioFormat); // NEW ios7
        OSStatus rc =  AudioQueueGetProperty(recordQueue, kAudioQueueProperty_StreamDescription, &audioFormat, &size); // NEW ios7
         
        if (rc) {
                           NSLog(@"AudioQueueGetProperty(CurrentLevelMeter) returned %ld", rc);
        }*/
            
        OSStatus errorStatus = AudioQueueStart(recordQueue, NULL);
        if (errorStatus) {
                NSLog(@"\n\n ERROR : Error %ld on AudioQueueStart\n", errorStatus );
        }
                           
        char str[150];
                           
        NSLog(@"PPPP C5 %s", FormatError(str, errorStatus));
        
        
        
        if (autoStop) {
            [self stopRecording:TRUE];
            
        }
              
    });
    
    
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
    [self stopRecording:FALSE];
}

- (void)stopRecording:(BOOL) autoStop
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
    if (recordQueue != nil) {
        NSString *osVersion = [[UIDevice currentDevice]  systemVersion];
        
        if ([osVersion doubleValue]<6){
            AudioQueueDispose(recordQueue, TRUE);
        }
        else {
            AudioQueueStop(recordQueue, FALSE);
        }
        
        recordQueue = nil;
    }
    
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
    
    if (autoStop) {
        NSLog(@"EVA IS READY");
        
        if ([_delegate respondsToSelector:@selector(recorderIsReady)]) {
#if DEBUG_RECORDER
            NSLog(@"respondsToSelector:@selector(recorderIsReady)");
#endif
            [_delegate recorderIsReady];
            
        }else{

#if DEBUG_RECORDER
            NSLog(@"Error with respondsToSelector:@selector(recorderIsReady)");
#endif
        }
        isRecorderReady = TRUE;
    }
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
    
    Recorder *userRecoreder =(__bridge Recorder*)client_data;
    
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
    [[(__bridge Recorder*)client_data delegate] dataSend:(void*)buffer withLength:bytes ];
    
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
		/////init_status = FLAC__stream_encoder_init_file(_encoder, [_savedPath UTF8String], NULL, NULL);
        
        init_status = FLAC__stream_encoder_init_file(_encoder, [_savedPath UTF8String], progress_callback, (__bridge void *)(self));
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
    ////[super dealloc];
    
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
    
	//[super dealloc];
}

@end
