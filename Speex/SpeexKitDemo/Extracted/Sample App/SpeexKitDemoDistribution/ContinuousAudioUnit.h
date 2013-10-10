
#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR // The simulator uses an audio queue driver because it doesn't work at all with the low-latency audio unit driver. 
#import "AudioQueueFallback.h"

#else // The real driver is the low-latency audio unit driver:

#import <AudioToolbox/AudioToolbox.h>
#import "AudioConstants.h"


    
typedef SInt16 int16;
typedef SInt32 int32;
    
typedef struct Chunk { // The audio device struct used by Pocketsphinx.
	SInt16 *buffer; // The buffer of SInt16 samples
	SInt32 numberOfSamples; // The number of samples in the buffer
	CFAbsoluteTime writtenTimestamp; // When this buffer was written
} RingBuffer;	
	
typedef struct {

	AudioUnit audioUnit;
	AudioStreamBasicDescription thruFormat;
	int16 deviceIsOpen;
	int16 unitIsRunning;
	CFStringRef currentRoute; // The current Audio Route for the device (e.g. headphone mic or external mic).
	SInt64 recordPacket; // The current packet of the Audio unit.
	BOOL recordData; // Should data be recorded?
	BOOL recognitionIsInProgress; // Is the recognition loop in effect?
	BOOL audioUnitIsRunning; // Is the unit instantiated? 
	BOOL recording; // Is the Audio unit currently recording sound? 
	SInt32 sps;		// Samples per second.
	SInt32 bps;		// Bytes per sample.
    Float32 pocketsphinxDecibelLevel; // The decibel level of mic input
	int callbacks;
    
} pocketsphinxAudioDevice;	


@protocol ContinuousAudioUnitDelegate;

@interface ContinuousAudioUnit : NSObject  {
    __unsafe_unretained id<ContinuousAudioUnitDelegate> delegate;
}

@property (assign) id<ContinuousAudioUnitDelegate> delegate;

Float32 pocketsphinxAudioDeviceMeteringLevel(pocketsphinxAudioDevice * audioDriver); // Returns the decibel level of mic input to controller classes
pocketsphinxAudioDevice *openAudioDevice(const char *dev, int32 samples_per_sec); // Opens the audio device
int32 startRecording(pocketsphinxAudioDevice * audioDevice); // Starts the audio device
int32 stopRecording(pocketsphinxAudioDevice * audioDevice); // Stops the audio device
int32 closeAudioDevice(pocketsphinxAudioDevice * audioDevice); // Closes the audio device
void setRoute(); // Sets the audio route as read from the audio session manager
void getDecibels(SInt16 * samples, UInt32 inNumberFrames); // Reads the buffer samples and converts them to decibel readings

- (id) initWithDelegate:(id)initdelegate;

@end

@protocol ContinuousAudioUnitDelegate <NSObject>
@optional 

- (void) samplesAvailable:(SInt16 *)samples withNumberOfSamples:(int)numberOfSamples;

@end

#endif