#import "SoundRecoder.h"
#import <AVFoundation/AVFoundation.h>
#import <FLAC/all.h>
#import "Recorder.h"

#define SAMPLE_RATE 16000.0 // Need to put inside code.

@interface SoundRecoder () <AVCaptureAudioDataOutputSampleBufferDelegate>{
	AVCaptureSession *_session;
	int  _frameIndex;
	BOOL _ready;
	int  _sampleRate;
	int  _totalSampleCount;
	int  _maxSampleCount;
	NSString *_savedPath;
	///////////////////////
	FLAC__StreamEncoder *_encoder;
	int32_t *_buffer;
	int32_t  _bufferCapacity;
}
@end

@implementation SoundRecoder

@synthesize delegate = _delegate;
@synthesize savedPath = _savedPath;

-(id)init{
    OSStatus error;
    
    union
    {
        OSStatus propertyResult;
        char a[4];
    } u;
    
    //Float64 F64sampleRate = 8192.0;
    Float64 F64sampleRate = SAMPLE_RATE;
    
    Float64 F64realSampleRate = 0;
    UInt32 F64datasize = 8;
    
    
    
	self = [super init];
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(isInputAvailable)]){
        if( ![audioSession isInputAvailable] ){
            NSLog(@"No sound input available");
            return FALSE;
        }
    }
    else{
        // Need to check the case of iOS 5
        NSLog(@"No isInputAvailable function");
          //  return FALSE;
    }
    
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setPreferredSampleRate:SAMPLE_RATE error:&err];
    
    double trueSampleRate = SAMPLE_RATE;
	if([[AVAudioSession sharedInstance] respondsToSelector:@selector(setPreferredSampleRate:error:)]) {
		[[AVAudioSession sharedInstance] setPreferredSampleRate:SAMPLE_RATE error:&err];
		trueSampleRate = [audioSession sampleRate];
	} else if([[AVAudioSession sharedInstance] respondsToSelector:@selector(setPreferredHardwareSampleRate:error:)]) {
		[[AVAudioSession sharedInstance] setPreferredHardwareSampleRate:SAMPLE_RATE error:&err];
		trueSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
	}
    
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
    //[audioSession setPreferredHardwareSampleRate:SAMPLE_RATE error:nil];
    

    
    UInt32 propertySize = sizeof (trueSampleRate);    // 1
    
    AudioSessionSetProperty (                                  // 2
                             kAudioSessionProperty_CurrentHardwareSampleRate,
                             &propertySize,
                             &trueSampleRate
                             );

    NSLog(@"%@", err);
	/*error = AudioSessionInitialize(NULL, NULL, nil, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    
    UInt32 category = kAudioSessionCategory_RecordAudio;//kAudioSessionCategory_PlayAndRecord;
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error) printf("couldn't set audio category!");
    
    u.propertyResult = AudioSessionSetProperty (  kAudioSessionProperty_PreferredHardwareSampleRate ,sizeof(F64sampleRate) , &F64sampleRate );
    NSLog(@"Set Error Set Sample Rate %ld %lx %c%c%c%c",u.propertyResult,u.propertyResult,u.a[3],u.a[2],u.a[1],u.a[0]); */
    
    u.propertyResult = AudioSessionGetProperty ( kAudioSessionProperty_CurrentHardwareSampleRate , &F64datasize, &F64realSampleRate );
    NSLog(@"Get Error Current Sample Rate %ld %lx %c%c%c%c",u.propertyResult,u.propertyResult,u.a[3],u.a[2],u.a[1],u.a[0]);
    NSLog(@"Sample Rate is %f",F64realSampleRate);
    
    NSTimeInterval bufferDuration = 512 / trueSampleRate;
	[audioSession setPreferredIOBufferDuration:bufferDuration error:&err];
    
   // AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate ,sizeof(F64sampleRate) , &F64sampleRate );
    //
    //error = AudioSessionSetActive(true);
    //if (error) printf("AudioSessionSetActive (true) failed");
    
	_session = [[AVCaptureSession alloc] init];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
	[_session addInput:input];
	AVCaptureAudioDataOutput *output = [[AVCaptureAudioDataOutput alloc] init];
   
    [output setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0)]; //new
    //[output setSampleBufferDelegate:self queue:dispatch_get_main_queue()]; //NEW
	[_session addOutput:output];

	[output release];
	
	_maxSampleCount = SAMPLE_RATE*10; // 10sec
    
    
	
	return self;
}



- (void)dealloc
{
    [_session release];
	if( _buffer ){
		free(_buffer);
	}
    [super dealloc];
}

-(BOOL)startRecording:(NSString*)savePath{
	if( !_session || [_session isRunning] ){
		return FALSE;
	}
	[_savedPath release];
	_savedPath = [savePath copy];
	AVCaptureAudioDataOutput *output = [[_session outputs] objectAtIndex:0];
    
	[output setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0)];
	_ready = NO;
	_frameIndex = 0;
	_totalSampleCount = 0;

	[_session startRunning];
    
    NSLog(@"%f", [[AVAudioSession sharedInstance] currentHardwareSampleRate]);
    
	return TRUE;
}

-(BOOL)stopRecording{
	if( ![_session isRunning] ){
		return FALSE;
	}
	_ready = NO;
	AVCaptureAudioDataOutput *output = [[_session outputs] objectAtIndex:0];
	[output setSampleBufferDelegate:nil queue:nil];
	[_session stopRunning];
	
	FLAC__stream_encoder_finish(_encoder);
	FLAC__stream_encoder_delete(_encoder);
	
	[_delegate soundRecoderDidFinishRecording:self];
	
	return TRUE;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	  fromConnection:(AVCaptureConnection *)connection{
	if( _frameIndex++==0 ){
		CMAudioFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
		const AudioStreamBasicDescription *desc = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
		if( !desc->mFormatID == kAudioFormatLinearPCM ){
			return;
		}
		if( desc->mChannelsPerFrame != 1 || desc->mBitsPerChannel != 16) {
			return;
		}
        
        NSLog(@"(int)desc->mSampleRate = %d", (int)desc->mSampleRate);
        NSLog(@"%f", [[AVAudioSession sharedInstance] currentHardwareSampleRate]);
		_sampleRate = (int)desc->mSampleRate;
		
		_encoder = FLAC__stream_encoder_new();
		FLAC__stream_encoder_set_verify(_encoder,true);
		FLAC__stream_encoder_set_compression_level(_encoder, 5);
		FLAC__stream_encoder_set_channels(_encoder,1);
		FLAC__stream_encoder_set_bits_per_sample(_encoder, 16);
		FLAC__stream_encoder_set_sample_rate(_encoder,_sampleRate);
		FLAC__stream_encoder_set_total_samples_estimate(_encoder, _maxSampleCount);
		FLAC__StreamEncoderInitStatus init_status;
		init_status = FLAC__stream_encoder_init_file(_encoder, [_savedPath UTF8String], NULL, NULL);
		if(init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
			NSLog(@"FLAC: Failed to initialize encoder: %s",
				  FLAC__StreamEncoderInitStatusString[init_status]);
			FLAC__stream_encoder_delete(_encoder);
			_encoder = NULL;
			return;
		}
		
		if( !_buffer ){
			_bufferCapacity = 4096;
			_buffer = (int32_t*)malloc(4*_bufferCapacity);
		}
		
		_ready = YES;
	}
	if( !_ready || !_buffer ){
		return;
	}
	CMBlockBufferRef audioBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
	size_t offset, length;
	int16_t *samples = NULL;
	CMBlockBufferGetDataPointer(audioBuffer, 0, &offset, &length, (char**)&samples);
	int sampleCount = CMSampleBufferGetNumSamples(sampleBuffer);
	
	if( sampleCount > _bufferCapacity ){
		free(_buffer);
		_bufferCapacity = sampleCount;
		_buffer = (int32_t*)malloc(4*_bufferCapacity);
	}
	
	for(int i=0;i<sampleCount;i++){
		_buffer[i] = samples[i];
	}
	
	FLAC__stream_encoder_process_interleaved(_encoder,_buffer,sampleCount);
	_totalSampleCount += sampleCount;
	
	if( _totalSampleCount > _maxSampleCount ){
		[self stopRecording];
	}
}

@end
