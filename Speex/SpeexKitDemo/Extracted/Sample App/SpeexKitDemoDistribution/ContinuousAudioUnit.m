#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR // This is the driver for the simulator only, since the low-latency audio unit driver doesn't work with the simulator at all.
#import "AudioQueueFallback.h"

#else

#import "ContinuousAudioUnit.h"

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


static pocketsphinxAudioDevice *audioDriver;

#pragma mark -
#pragma mark Audio Unit Callback
static OSStatus	AudioUnitRenderCallback (void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    audioDriver->callbacks++;
    
	if (inNumberFrames > 0) {
        
		OSStatus renderStatus = AudioUnitRender(audioDriver->audioUnit, ioActionFlags, inTimeStamp,1, inNumberFrames, ioData);
		
		if(renderStatus != noErr) {
			switch (renderStatus) {
				case kAudioUnitErr_InvalidProperty:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidProperty");
					break;
				case kAudioUnitErr_InvalidParameter:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidParameter");
					break;
				case kAudioUnitErr_InvalidElement:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidElement");
					break;
				case kAudioUnitErr_NoConnection:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_NoConnection");
					break;
				case kAudioUnitErr_FailedInitialization:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_FailedInitialization");
					break;
				case kAudioUnitErr_TooManyFramesToProcess:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_TooManyFramesToProcess");
					break;
				case kAudioUnitErr_InvalidFile:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidFile");
					break;
				case kAudioUnitErr_FormatNotSupported:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_FormatNotSupported");
					break;
				case kAudioUnitErr_Uninitialized:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_Uninitialized");
					break;
				case kAudioUnitErr_InvalidScope:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidScope");
					break;
				case kAudioUnitErr_PropertyNotWritable:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_PropertyNotWritable");
					break;
				case kAudioUnitErr_CannotDoInCurrentContext:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_CannotDoInCurrentContext");
					break;
				case kAudioUnitErr_InvalidPropertyValue:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidPropertyValue");
					break;
				case kAudioUnitErr_PropertyNotInUse:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_PropertyNotInUse");
					break;
				case kAudioUnitErr_InvalidOfflineRender:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_InvalidOfflineRender");
					break;
				case kAudioUnitErr_Unauthorized:
					OpenEarsLog(@"Audio Unit render error: kAudioUnitErr_Unauthorized");
					break;
				case -50:
					OpenEarsLog(@"Audio Unit render error: error in user parameter list (-50)");
					break;														
				default:
					OpenEarsLog(@"Audio Unit render error %d: unknown error", (int)renderStatus);
					break;
			}
			
			return renderStatus;
			
		} else { // if the render was successful,

            if(audioDriver->callbacks > 4) {
                SInt16 *samples = (SInt16 *)ioData->mBuffers[0].mData;
                [refToDelegate samplesAvailable:samples withNumberOfSamples:inNumberFrames];  // Send the AudioBufferList to the delegate method to get it out of here and into a view controller for Objective-C processing.
            }
            //getDecibels(samples,inNumberFrames); // Get the decibels
			
			memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize); // write out silence to the buffer for no-playback times
		}
		
	}

	return 0;
}

void getDecibels(SInt16 * samples, UInt32 inNumberFrames) {
	
	Float32 decibels = kDBOffset; // When we have no signal we'll leave this on the lowest setting
	Float32 currentFilteredValueOfSampleAmplitude; 
	Float32 previousFilteredValueOfSampleAmplitude = 0.0; // We'll need these in the low-pass filter
	Float32 peakValue = kDBOffset; // We'll end up storing the peak value here
	
	for (int i=0; i < inNumberFrames; i=i+10) { // We're incrementing this by 10 because there's actually too much info here for us for a conventional UI timeslice and it's a cheap way to save CPU
		
		Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
		
		// Step 3: for each sample's absolute value, run it through a simple low-pass filter
		// Begin low-pass filter
		currentFilteredValueOfSampleAmplitude = kLowPassFilterTimeSlice * absoluteValueOfSampleAmplitude + (1.0 - kLowPassFilterTimeSlice) * previousFilteredValueOfSampleAmplitude;
		previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
		Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
		// End low-pass filter
		
		Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + kDBOffset;
		// Step 4: for each sample's filtered absolute value, convert it into decibels
		// Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
		
		if((sampleDB == sampleDB) && (sampleDB <= DBL_MAX && sampleDB >= -DBL_MAX)) { // if it's a rational number and isn't infinite
			
			if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
			decibels = peakValue; // final value
		}
	}
	audioDriver->pocketsphinxDecibelLevel = decibels;
}
void setRoute(void);
void setRoute() {
	CFStringRef audioRoute;
	UInt32 audioRouteSize = sizeof(CFStringRef);
	OSStatus getAudioRouteStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &audioRouteSize, &audioRoute); // Get the audio route.
	if (getAudioRouteStatus != 0) {
		OpenEarsLog(@"Error %d: Unable to get the audio route.", (int)getAudioRouteStatus);
	} else {
		OpenEarsLog(@"Set audio route to %@", (NSString *)audioRoute);	
	}
	
	audioDriver->currentRoute = audioRoute; // Set currentRoute to the audio route.
}

#pragma mark -
#pragma mark Pocketsphinx driver functionality

pocketsphinxAudioDevice *openAudioDevice(const char *dev, int32 samples_per_sec) {
    
	OpenEarsLog(@"Starting openAudioDevice on the device.");
					
	if(audioDriver != NULL) { // Audio unit wrapper has already been created
		closeAudioDevice(audioDriver);
	}
	
	if ((audioDriver = (pocketsphinxAudioDevice *) calloc(1, sizeof(pocketsphinxAudioDevice))) == NULL) {
		OpenEarsLog(@"There was an error while creating the device, returning null device.");
		return NULL;
	} else {
		OpenEarsLog(@"Audio unit wrapper successfully created.");
	}
	
	audioDriver->audioUnitIsRunning = 0;
	audioDriver->recording = 0;
	audioDriver->sps = kSamplesPerSecond;
	audioDriver->bps = kBitsPerChannel/8;
	audioDriver->pocketsphinxDecibelLevel = 0.0;
    audioDriver->callbacks = 0;
    
	AURenderCallbackStruct inputProc;
	inputProc.inputProc = AudioUnitRenderCallback;
	inputProc.inputProcRefCon = audioDriver;
	
	AudioComponentDescription auDescription;
	
	auDescription.componentType = kAudioUnitType_Output;
	auDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	auDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	auDescription.componentFlags = 0;
	auDescription.componentFlagsMask = 0;
	
	AudioComponent component = AudioComponentFindNext(NULL, &auDescription);
	
	OSStatus newAudioUnitComponentInstanceStatus = AudioComponentInstanceNew(component, &audioDriver->audioUnit);
	if(newAudioUnitComponentInstanceStatus != noErr) {
		OpenEarsLog(@"Couldn't get new audio unit component instance: %d",(int)newAudioUnitComponentInstanceStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}

	UInt32 maximumFrames = 4096;
	OSStatus maxFramesStatus = AudioUnitSetProperty(audioDriver->audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFrames, sizeof(maximumFrames));
	if(maxFramesStatus != noErr) {
		OpenEarsLog(@"Error %d: unable to set maximum frames property.", (int)maxFramesStatus);
	}
	
	UInt32 enableIO = 1;
	
	OSStatus setEnableIOStatus = AudioUnitSetProperty(audioDriver->audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
	if(setEnableIOStatus != noErr) {
		OpenEarsLog(@"Couldn't enable IO: %d",(int)setEnableIOStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}
	
	OSStatus setRenderCallbackStatus = AudioUnitSetProperty(audioDriver->audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &inputProc, sizeof(inputProc));
	if(setRenderCallbackStatus != noErr) {
		OpenEarsLog(@"Couldn't set render callback: %d",(int)setRenderCallbackStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}
	
	audioDriver->thruFormat.mChannelsPerFrame = 1; 
	audioDriver->thruFormat.mSampleRate = kSamplesPerSecond; 
	audioDriver->thruFormat.mFormatID = kAudioFormatLinearPCM;
	audioDriver->thruFormat.mBytesPerPacket = audioDriver->thruFormat.mChannelsPerFrame * audioDriver->bps;
	audioDriver->thruFormat.mFramesPerPacket = 1;
	audioDriver->thruFormat.mBytesPerFrame = audioDriver->thruFormat.mBytesPerPacket;
	audioDriver->thruFormat.mBitsPerChannel = kBitsPerChannel; 
	audioDriver->thruFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
	
	OSStatus setInputFormatStatus = AudioUnitSetProperty(audioDriver->audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioDriver->thruFormat, sizeof(audioDriver->thruFormat));
	if(setInputFormatStatus != noErr) {
		OpenEarsLog(@"Couldn't set stream input format: %d",(int)setInputFormatStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}
	
	OSStatus setOutputFormatStatus = AudioUnitSetProperty(audioDriver->audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &audioDriver->thruFormat, sizeof(audioDriver->thruFormat));
	if(setOutputFormatStatus != noErr) {
		OpenEarsLog(@"Couldn't set stream output format: %d",(int)setOutputFormatStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}
	
	OSStatus audioUnitInitializeStatus = AudioUnitInitialize(audioDriver->audioUnit);
	if(audioUnitInitializeStatus != noErr) {
		
		OpenEarsLog(@"Couldn't initialize audio unit: %d", (int)audioUnitInitializeStatus);
		audioDriver->unitIsRunning = 0;
		return NULL;
	}
	
	audioDriver->unitIsRunning = 1;			
	audioDriver->deviceIsOpen = 1;
	
	setRoute();
	
    return audioDriver;
}

int32 startRecording(pocketsphinxAudioDevice * audioDevice) {
	
	if (audioDriver->recording == 1) {
		OpenEarsLog(@"This driver is already recording, returning.");
        return -1;
	}
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetAllAudioSessionSettings" object:nil]; // We'll first check that all the audio session settings are correct for recognition and fix them if not.
    
	OpenEarsLog(@"Setting the variables for the device and starting it.");
	
	OSStatus startAudioUnitOutputStatus = AudioOutputUnitStart(audioDriver->audioUnit);
	if(startAudioUnitOutputStatus != noErr) {
		OpenEarsLog(@"Couldn't start audio unit output: %d", (int)startAudioUnitOutputStatus);	
		return -1;
	} else {
		OpenEarsLog(@"Started audio output unit.");		
	}

	audioDriver->audioUnitIsRunning = 1; // Set audioUnitIsRunning to true.
	
	audioDriver->recording = 1;
	
    return 0;
}

int32 stopRecording(pocketsphinxAudioDevice * audioDevice) {
	
	if (audioDriver->recording == 0) {
		OpenEarsLog(@"Can't stop audio device because it isn't currently recording, returning instead.");	
		return -1; // bail if this ad doesn't think it's recording
	}
	
	if(audioDriver->audioUnitIsRunning == 1) { // only stop recording if there is actually a unit
		OpenEarsLog(@"Stopping audio unit.");	

		OSStatus stopAudioUnitStatus = AudioOutputUnitStop(audioDriver->audioUnit);
		if(stopAudioUnitStatus != noErr) {
			OpenEarsLog(@"Couldn't stop audio unit: %d", (int)stopAudioUnitStatus);
			return -1;
		} else {
			OpenEarsLog(@"Audio Output Unit stopped, cleaning up variable states.");	
		}
		
	} else {
		OpenEarsLog(@"Cleaning up driver variable states.");	
	}

	audioDriver->recording = 0;
	
    return 0;
}

Float32 pocketsphinxAudioDeviceMeteringLevel(pocketsphinxAudioDevice * audioDriver) { // Function which returns the metering level of the AudioUnit input.

	if(audioDriver != NULL && audioDriver->pocketsphinxDecibelLevel && audioDriver->pocketsphinxDecibelLevel > -161 && audioDriver->pocketsphinxDecibelLevel < 1) {
		return audioDriver->pocketsphinxDecibelLevel;
	}
	return 0.0;	
}

int32 closeAudioDevice(pocketsphinxAudioDevice * audioDevice) {
	

	
	if (audioDriver->recording == 1) {
		OpenEarsLog(@"This device is recording, so we will first stop it");
		stopRecording(audioDriver);
		audioDriver->recording = 0;

	} else {
		OpenEarsLog(@"This device is not recording, so first we will set its recording status to 0");
		audioDriver->recording = 0;
	}

	if(audioDriver->audioUnitIsRunning == 1) {
		OpenEarsLog(@"The audio unit is running so we are going to dispose of its instance");		
		OSStatus instanceDisposeStatus = AudioComponentInstanceDispose(audioDriver->audioUnit);
		
		if(instanceDisposeStatus != noErr) {
			OpenEarsLog(@"Couldn't dispose of audio unit instance: %d", (int)instanceDisposeStatus);
			return -1;
		}

		audioDriver->audioUnit = nil;
	}
	
	if(audioDriver != NULL) {
		audioDriver->deviceIsOpen = 0;	
		free(audioDriver); 	// Finally, free the audio device.
		audioDriver = NULL;
	}
	
    return 0;
}

#pragma -
#pragma Delegate methods

- (void) samplesAvailable:(SInt16 *)samples withNumberOfSamples:(int)numberOfSamples {
    
}

@end

#endif