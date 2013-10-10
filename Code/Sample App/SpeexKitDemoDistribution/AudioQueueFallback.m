//  OpenEars version 1.0
//  http://www.politepix.com/openears
//
//  AudioQueueFallback.mm
//  OpenEars
//

#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR

#import "AudioQueueFallback.h"
#import "ContinuousAudioUnit.h"
#import "AudioConstants.h"

@implementation ContinuousAudioUnit
@synthesize delegate;

id refToSelf;
id refToDelegate;

- (id) initWithDelegate:(id)initdelegate {
    if (self = [super init]) {
        
        refToSelf = self;
        delegate = initdelegate;
        refToDelegate = delegate;
    }
    return self;
}

#define kPredictedSizeOfRenderFramesPerCallbackRoundAudioQueue 8092 * 10

static pocketsphinxAudioDevice *audioDriver; // The struct that contains all of the Audio Queue- and Pocketsphinx-required elements.

#pragma mark -
#pragma mark Audio Queue functions

void AudioQueueInputBufferCallback(void *inUserData,
								   AudioQueueRef inAudioQueue,
								   AudioQueueBufferRef inBuffer,
								   const AudioTimeStamp *inStartTime,
								   UInt32 inNumberOfPackets,
								   const AudioStreamPacketDescription *inPacketDescription) { // This is the buffer callback for the AudioQueue.
	
	// If there are packets, we can write them to the record file here if recognition isn't suspended and speech isn't in progress.
	audioDriver->callbacks++;
	if (inNumberOfPackets > 0) {
		
        if(audioDriver->callbacks > 1) {
            SInt16 *samples = (SInt16 *)inBuffer->mAudioData;
            [refToDelegate samplesAvailable:samples withNumberOfSamples:inNumberOfPackets];

        }
	}
	
	// If we're still working, re-enqueue the buffer so it is refilled.
	if (audioDriver->audioQueueIsRunning == 1) {
		OSStatus enqueueBufferError =AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
		if(enqueueBufferError != 0) {
#ifdef SPEEXLOGGING			
			printf("Error %d: Unable to enqueue buffer.\n", (int)enqueueBufferError);
#endif			
		}
	}
}

#pragma mark -
#pragma mark Continuous recognition audio driver functions

pocketsphinxAudioDevice *openAudioDevice (const char *audioDevice, SInt32 samplesPerSecond) { // Function to open the "audio device" or in this case instantiate a new Audio Queue.
	OpenEarsLog(@"Starting openAudioDevice on the simulator. This Simulator-compatible audio driver is only provided to you as a convenience so you can use the Simulator to test recognition logic, however, its audio driver is not supported and bug reports for it will be circular-filed.");
    if ((audioDriver = (pocketsphinxAudioDevice *) calloc(1, sizeof(pocketsphinxAudioDevice))) == NULL) {
        return NULL;
	}
	
	// Set the initial values for the device.
	audioDriver->audioQueueIsRunning = 0;
	audioDriver->recording = 0;
	audioDriver->sps = 16000;
    audioDriver->bps = 2;
	audioDriver->callbacks = 0;
    
	CFStringRef audioRoute;
	UInt32 audioRouteSize = sizeof(CFStringRef);
	OSStatus getAudioRouteError = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &audioRouteSize, &audioRoute); // Get the audio route.
	if (getAudioRouteError != 0) {
#ifdef SPEEXLOGGING			
		printf("Error %d: Unable to get the audio route.\n", (int)getAudioRouteError);
#endif
	}
	
	audioDriver->currentRoute = audioRoute; // Set currentRoute to the audio route.
	
    return audioDriver;	
}

SInt32 startRecording(pocketsphinxAudioDevice * audioDevice) { // Tell the Audio Queue to start recording.
	
	if (audioDriver->recording == 1) { // Don't start recording if we're already recording.
        return -1;
	}

	// Set the parameters of the recording format.
	
	memset(&audioDriver->audioQueueRecordFormat, 0, sizeof(audioDriver->audioQueueRecordFormat));
	
	UInt32 size = sizeof(audioDriver->audioQueueRecordFormat.mSampleRate);
	OSStatus sampleRateError = AudioSessionGetProperty(	kAudioSessionProperty_CurrentHardwareSampleRate,
													   &size, 
													   &audioDriver->audioQueueRecordFormat.mSampleRate);
	if(sampleRateError != 0) {
#ifdef SPEEXLOGGING		
		printf("Error %d: Unable to get hardware sample rate.\n", (int)sampleRateError);
#endif
	}
	
	size = sizeof(audioDriver->audioQueueRecordFormat.mChannelsPerFrame);
	OSStatus inputNumberChannelsError = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, 
																&size, 
																&audioDriver->audioQueueRecordFormat.mChannelsPerFrame);
	if(inputNumberChannelsError != 0) {
#ifdef SPEEXLOGGING		
		printf("Error %d: Unable to get number of input channels\n", (int)inputNumberChannelsError);
#endif
	}
	
	audioDriver->audioQueueRecordFormat.mFormatID = kAudioFormatLinearPCM;
	audioDriver->audioQueueRecordFormat.mChannelsPerFrame = 1; 
	audioDriver->audioQueueRecordFormat.mSampleRate = 16000; 
	audioDriver->audioQueueRecordFormat.mBytesPerPacket = audioDriver->audioQueueRecordFormat.mChannelsPerFrame * 2;
	audioDriver->audioQueueRecordFormat.mFramesPerPacket = 1;
	audioDriver->audioQueueRecordFormat.mBytesPerFrame = audioDriver->audioQueueRecordFormat.mBytesPerPacket;
	audioDriver->audioQueueRecordFormat.mBitsPerChannel = 16; 
	audioDriver->audioQueueRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;

	// Create a new Audio Queue for recording, using the defined format.
	
	OSStatus audioQueueNewInputError = AudioQueueNewInput(&audioDriver->audioQueueRecordFormat,
														  AudioQueueInputBufferCallback,
														  audioDriver,
														  NULL, 
														  NULL,
														  0, 
														  &audioDriver->audioQueue);
	if(audioQueueNewInputError != 0) {
#ifdef SPEEXLOGGING		
		printf("Error %d: Unable to queue new audio input\n", (int)audioQueueNewInputError);
#endif
	}
	audioDriver->audioQueueIsRunning = 1; // Set audioQueueIsRunning to true.

	SInt32 bufferByteSize = 16000;
	
	for (int i = 0; i < 3; ++i) { 
		
		OSStatus allocateBufferError = AudioQueueAllocateBuffer(audioDriver->audioQueue, bufferByteSize, &audioDriver->audioQueueBuffers[i]);
		if(allocateBufferError != 0) {
#ifdef SPEEXLOGGING			
			printf("Error %d: Unable to allocate Audio Queue buffer.\n", (int)allocateBufferError);
#endif
		}
		
		// Enqueue the buffers.
		
		OSStatus enqueueBufferError = AudioQueueEnqueueBuffer(audioDriver->audioQueue, audioDriver->audioQueueBuffers[i], 0, NULL);
		if(enqueueBufferError != 0) {
#ifdef SPEEXLOGGING			
			printf("Error %d: Unable to enqueue the Audio Queue buffer.\n", (int)enqueueBufferError);
#endif
		}
	}
	
	// Start the audio queue.
	
	OSStatus audioQueueStartError = AudioQueueStart(audioDriver->audioQueue, NULL);
	if(audioQueueStartError != 0) {
#ifdef SPEEXLOGGING		
		printf("Error %d: Unable to start the Audio Queue.\n", (int)audioQueueStartError);
#endif
	}
	
	// Enable metering.
	
	UInt32 enableMetering = 1;
	OSStatus audioQueueSetPropertyError = AudioQueueSetProperty(audioDriver->audioQueue, kAudioQueueProperty_EnableLevelMetering, &enableMetering, sizeof(UInt32));
	if(audioQueueSetPropertyError != 0) {
#ifdef SPEEXLOGGING		
		printf("Error %d: Unable to enable Audio Queue level metering.\n", (int)audioQueueSetPropertyError);
#endif
	}
	
    audioDriver->recording = 1;
	
    return 0;
}

SInt32 stopRecording(pocketsphinxAudioDevice * audioDevice) { // Tell the Audio Queue to stop recording.
	// If the device isn't actually recording, bail.
	
	if (audioDriver->recording == 0) {
        return -1;
	}
	
	// Dispose of the queue and close the audio file. If we've already done this there won't be a recordFileName.
	// This should really be checking the status of recordFileID or recording, but is a weird leftover from a previous 
	// approach that has already been tested that I'd like to change when there's time.
	
	
	if(audioDriver->audioQueueIsRunning == 1) {
		
		audioDriver->audioQueueIsRunning = 0;
		OSStatus audioQueueStopError = AudioQueueStop(audioDriver->audioQueue, true);
		if(audioQueueStopError != 0) {
#ifdef SPEEXLOGGING				
			printf("Error %d: Unable to stop the Audio Queue.\n", (int)audioQueueStopError);
#endif
		}

		OSStatus audioQueueDisposeError = AudioQueueDispose(audioDriver->audioQueue, true);
		if(audioQueueDisposeError != 0) {
#ifdef SPEEXLOGGING				
			printf("Error %d: Unable to dispose of the Audio Queue.\n", (int)audioQueueDisposeError);
#endif
		}

	}
	    
	if(audioDriver) audioDriver->recording = 0;
	
    return 0;
}

SInt32 closeAudioDevice(pocketsphinxAudioDevice * audioDevice) { // Close the "audio device" or in this case stop and free the Audio Queue.
	// First clean up if this has somehow been called out of sequence.
	
	if (audioDevice && audioDevice->recording == 1) {
		
		stopRecording(audioDevice);
		audioDevice->recording = 0;
		
	} else {
		
		audioDevice->recording = 0;
	}
	
	// If there is an audio queue and it's running, dispose of it.
	if(audioDevice->audioQueue && audioDevice->audioQueueIsRunning == 1) {
		AudioQueueDispose(audioDevice->audioQueue, true);
		audioDevice->audioQueue = NULL;
	}
	
	if(audioDevice) free(audioDevice); 	// Finally, free the Sphinx audio device.
	
    return 0;
}

- (void) samplesAvailable:(SInt16 *)samples withNumberOfSamples:(int)numberOfSamples { // Delegate method for other classes to use.
    
}

@end
#else
#endif