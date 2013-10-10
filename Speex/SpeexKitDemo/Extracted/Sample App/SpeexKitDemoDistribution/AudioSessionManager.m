//  OpenEars version 1.0
//  http://www.politepix.com/openears
//
//  AudioSessionManager.m
//  OpenEars
//
//  AudioSessionManager is a class for initializing the Audio Session and forwarding changes in the Audio
//  Session to the OpenEarsEventsObserver class so they can be reacted to when necessary.
//
//  Copyright Politepix UG (haftungsbeschränkt) 2012. All rights reserved.
//  http://www.politepix.com
//  Contact at http://www.politepix.com/contact
//
//  This file is licensed under the Politepix Shared Source license found in the root of the source distribution.

#import "AudioSessionManager.h"
@implementation AudioSessionManager
@synthesize soundMixing;

void audioSessionInterruptionListener(void *inClientData,
									  UInt32 inInterruptionState);
void performRouteChange(void);
void audioSessionPropertyListener(void *inClientData,
								  AudioSessionPropertyID inID,
								  UInt32 inDataSize,
								  const void *inData);

void audioSessionPropertyListener(void *inClientData,
								  AudioSessionPropertyID inID,
								  UInt32 inDataSize,
								  const void *inData);






//- (void)dealloc {
//
//       [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [super dealloc];
//}

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setAllAudioSessionSettings) 
                                                     name:@"SetAllAudioSessionSettings"
                                                   object:nil];
        self.soundMixing = FALSE;
    }
    return self;
}





void audioSessionInterruptionListener(void *inClientData,
									  UInt32 inInterruptionState) { // Listen for interruptions to the Audio Session.
	
	
	// It's important on the iPhone to have the ability to react to an interruption in app audio such as an incoming or user-initiated phone call.
	// For Pocketsphinx it might be necessary to restart the recognition loop afterwards, or the app's UI might need to be reset or redrawn. 
	// By observing for the AudioSessionInterruptionDidBegin and AudioQueueInterruptionEnded NSNotifications and forwarding them to OpenEarsEventsObserver,
	// the developer using OpenEars can react to an interruption.
	 
	if (inInterruptionState == kAudioSessionBeginInterruption) { // There was an interruption.

		
		OpenEarsLog("The Audio Session was interrupted.");
		NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObject:@"AudioSessionInterruptionDidBegin" forKey:@"OpenEarsNotificationType"]; // Send notification to OpenEarsEventsObserver.
		NSNotification *notification = [NSNotification notificationWithName:@"OpenEarsNotification" object:nil userInfo:userInfoDictionary];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
		
		
	} else if (inInterruptionState == kAudioSessionEndInterruption) { // The interruption is over.
	
		NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObject:@"AudioSessionInterruptionDidEnd" forKey:@"OpenEarsNotificationType"]; // Send notification to OpenEarsEventsObserver.
		NSNotification *notification = [NSNotification notificationWithName:@"OpenEarsNotification" object:nil userInfo:userInfoDictionary];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
		OpenEarsLog("The Audio Session interruption is over.");
	}
}

void performRouteChange() {
	
	OpenEarsLog(@"Performing Audio Route change.");
	CFStringRef audioRoute;
	UInt32 size = sizeof(CFStringRef);
	OSStatus getAudioRouteError = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &audioRoute); /* Get the new route */
	
	if (getAudioRouteError != 0) {
		OpenEarsLog("Error %d: Unable to get new audio route.", (int)getAudioRouteError);
	} else {
		
		OpenEarsLog("The new audio route is %@",(NSString *)audioRoute);			
		
		NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"AudioRouteDidChangeRoute",[NSString stringWithFormat:@"%@",audioRoute],nil] forKeys:[NSArray arrayWithObjects:@"OpenEarsNotificationType",@"AudioRoute",nil]];
		NSNotification *notification = [NSNotification notificationWithName:@"OpenEarsNotification" object:nil userInfo:userInfoDictionary];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES]; // Forward the audio route change to OpenEarsEventsObserver.
	}

}


void audioSessionPropertyListener(void *inClientData,
								  AudioSessionPropertyID inID,
								  UInt32 inDataSize,
								  const void *inData) { // We also listen to some Audio Session properties so that we can react to changes such as new audio routes (e.g. headphones plugged/unplugged).
	
	 // It may be necessary to react to changes in the audio route; for instance, if the user inserts or removes the headphone mic, 
	 // it's probably necessary to restart a continuous recognition loop in order to calibrate to the changed background levels.
	 
	
	if (inID == kAudioSessionProperty_AudioRouteChange) { // If the property change triggering the function is a change of audio route,

#ifdef SPEEXLOGGING
		CFStringRef audioRouteOldRoute = (CFStringRef)[(NSDictionary *)inData valueForKey:(NSString *)CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute)];
#endif		
		CFNumberRef audioRouteChangeReasonKey = (CFNumberRef)CFDictionaryGetValue((CFDictionaryRef)inData, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 audioRouteChangeReason;
		CFNumberGetValue(audioRouteChangeReasonKey, kCFNumberSInt32Type, &audioRouteChangeReason); // Get the reason for the route change.
			
		OpenEarsLog(@"Audio route has changed for the following reason:");
		
		BOOL performChange = TRUE;
		
		// We only want to perform the OpenEars full-on notification and delegate method route change for a device change or a wake from sleep. We don't want to do it for programmatic changes to the audio session or mysterious reasons.
		
		switch (audioRouteChangeReason) {
			case kAudioSessionRouteChangeReason_Unknown:
				performChange = FALSE;
				OpenEarsLog(@"Reason unknown");
				break;
			case kAudioSessionRouteChangeReason_NewDeviceAvailable:
				performChange = TRUE;
				OpenEarsLog(@"A new device has become available");
				break;	
			case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
				performChange = TRUE;
				OpenEarsLog(@"An old device has become unavailable");
				break;
			case kAudioSessionRouteChangeReason_CategoryChange:
				performChange = FALSE;
				OpenEarsLog(@"There has been a change of category");
				break;	
			case kAudioSessionRouteChangeReason_Override:
				performChange = FALSE;
				OpenEarsLog(@"There has been an override to the audio session");
				break;
			case kAudioSessionRouteChangeReason_WakeFromSleep:
				performChange = TRUE;
				OpenEarsLog(@"The device has awoken from sleep");
				break;	
			case kAudioSessionRouteChangeReason_NoSuitableRouteForCategory:
				performChange = FALSE;
				OpenEarsLog(@"There is no suitable route for the category");
				break;				
			default:
				performChange = FALSE;
				OpenEarsLog(@"Unknown reason");
				break;
		}

		OpenEarsLog(@"The previous audio route was %@", (NSString *)audioRouteOldRoute);

		CFStringRef audioRoute;
		UInt32 size = sizeof(CFStringRef);
		OSStatus getAudioRouteError = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &audioRoute);
		if(getAudioRouteError) {
			OpenEarsLog(@"Error getting current audio route: %d", (int)getAudioRouteError);	
		}
		
		if(performChange == TRUE) {
	
			OpenEarsLog(@"This is a case for performing a route change. Before the route change, the current route is %@",(NSString *)audioRoute);
			performRouteChange();
		} else {
			OpenEarsLog(@"This is not a case in which OpenEars performs a route change voluntarily. At the close of this function, the audio route is %@",(NSString *)audioRoute);
		}
		
	} else if (inID == kAudioSessionProperty_AudioInputAvailable) {
		
		 // Here we're listening and sending notifications for changes in the availability of the input device.
		 
		OpenEarsLog("There was a change in input device availability: ");
		if (inDataSize == sizeof(UInt32)) {
			UInt32 audioInputIsAvailable = *(UInt32*)inData;
			if(audioInputIsAvailable == 0) { // Input became unavailable.
				
				NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObject:@"AudioInputDidBecomeUnavailable" forKey:@"OpenEarsNotificationType"];
				NSNotification *notification = [NSNotification notificationWithName:@"OpenEarsNotification" object:nil userInfo:userInfoDictionary];
				[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES]; // Forward the input availability change to OpenEarsEventsObserver.
				OpenEarsLog("the audio input is now unavailable.");
			} else if (audioInputIsAvailable == 1) { // Input became available again.
				
				OpenEarsLog(@"the audio input is now available.");
				NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObject:@"AudioInputDidBecomeAvailable" forKey:@"OpenEarsNotificationType"];
				NSNotification *notification = [NSNotification notificationWithName:@"OpenEarsNotification" object:nil userInfo:userInfoDictionary];
				[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES]; // Forward the input availability change to OpenEarsEventsObserver.
			}
		}
	}
}




- (void) setAllAudioSessionSettings {


    // Projects using Pocketsphinx and Flite should use the Audio Session Category kAudioSessionCategory_PlayAndRecord.
    // Using this category routes playback to the ear speaker when the headphones aren't plugged in.
    // This isn't really appropriate for a speech recognition/tts app as far as I can see so I'm re-routing the output to the 
    // main speaker.
    
    OpenEarsLog(@"Checking and resetting all audio session settings.");

    
    
    
    
    
    UInt32 audioInputAvailable = 0; 
    UInt32 size = sizeof(audioInputAvailable);
    OSStatus audioInputAvailableError = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &audioInputAvailable);
    if (audioInputAvailableError != noErr) {
        OpenEarsLog(@"Error %d: Unable to get the availability of the audio input.", (int)audioInputAvailableError);
    }
    if(audioInputAvailableError == 0 && audioInputAvailable == 0) {
        OpenEarsLog(@"There is no audio input available.");
    } 
    
    
    /*
     kAudioSessionCategory_AmbientSound               = 'ambi',
     kAudioSessionCategory_SoloAmbientSound           = 'solo',
     kAudioSessionCategory_MediaPlayback              = 'medi',
     kAudioSessionCategory_RecordAudio                = 'reca',
     kAudioSessionCategory_PlayAndRecord              = 'plar',
     kAudioSessionCategory_AudioProcessing            = 'proc'
     */
    
    UInt32 audioCategoryClassification;
    if(audioInputAvailable == 1) {
        audioCategoryClassification = kAudioSessionCategory_PlayAndRecord;
    } else {
        audioCategoryClassification = kAudioSessionCategory_SoloAmbientSound;
    }
    UInt32 audioCategoryCheckSize = sizeof (UInt32);
    UInt32 audioCategoryCheck = 999;
    
    AudioSessionGetProperty (kAudioSessionProperty_AudioCategory, &audioCategoryCheckSize, &audioCategoryCheck);
   
    if(audioCategoryCheck == audioCategoryClassification) {
        OpenEarsLog(@"audioCategory is correct, we will leave it as it is.");   
    } else {
        OpenEarsLog(@"audioCategory is incorrect, we will change it."); 
        UInt32 audioCategory = audioCategoryClassification; // Set the Audio Session category to kAudioSessionCategory_PlayAndRecord.
        OSStatus audioCategoryStatus = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
        if (audioCategoryStatus != noErr) {
            OpenEarsLog(@"Error %d: Unable to set audio category.", (int)audioCategoryStatus);
        } else {
            if(audioCategoryClassification == kAudioSessionCategory_PlayAndRecord) {
                OpenEarsLog(@"audioCategory is now on the correct setting of kAudioSessionCategory_PlayAndRecord."); 
            } else {
                OpenEarsLog(@"audioCategory is now on the correct setting of kAudioSessionCategory_AmbientSound.");
            }
        }
    }

    
#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR
#else
    UInt32 bluetoothInputCheckSize = sizeof (UInt32);
    UInt32 bluetoothInputCheck = 999;
    
    AudioSessionGetProperty (kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, &bluetoothInputCheckSize, &bluetoothInputCheck);
    
    if(bluetoothInputCheck == 1) {
        OpenEarsLog(@"bluetoothInput is correct, we will leave it as it is.");   
    } else {
        OpenEarsLog(@"bluetoothInput is incorrect, we will change it."); 
        UInt32 bluetoothInput = 1;
        OSStatus bluetoothInputStatus = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,sizeof (bluetoothInput), &bluetoothInput);
        if (bluetoothInputStatus != noErr) {
            OpenEarsLog(@"Error %d: Unable to set bluetooth input.", (int)bluetoothInputStatus);
        } else {
            OpenEarsLog(@"bluetooth input is now on the correct setting of 1."); 
        }
    }
    
#endif   


#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR
#else    
    
    
    UInt32 categoryDefaultToSpeakerCheckSize = sizeof (UInt32);
    UInt32 categoryDefaultToSpeakerCheck = 999;
    
    AudioSessionGetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, &categoryDefaultToSpeakerCheckSize, &categoryDefaultToSpeakerCheck);
    
    if(categoryDefaultToSpeakerCheck == 1) {
        OpenEarsLog(@"categoryDefaultToSpeaker is correct, we will leave it as it is.");   
    } else {
        OpenEarsLog(@"categoryDefaultToSpeaker is incorrect, we will change it."); 
        
        UInt32 overrideCategoryDefaultToSpeaker = 1; // Re-route sound output to the main speaker.
        OSStatus overrideCategoryDefaultToSpeakerError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (overrideCategoryDefaultToSpeaker), &overrideCategoryDefaultToSpeaker);
        if (overrideCategoryDefaultToSpeakerError != noErr) {
            OpenEarsLog(@"Error %d: Unable to override the default speaker.", (int)overrideCategoryDefaultToSpeakerError);
        } else {
            OpenEarsLog(@"CategoryDefaultToSpeaker is now on the correct setting of 1.");
        }
    }

    if(self.soundMixing == TRUE) { // If the audioSessionManager soundmixing property is set to true, do the following. It defaults to false.
        UInt32 overrideCategoryMixWithOthersCheckSize = sizeof (UInt32);
        UInt32 overrideCategoryMixWithOthersCheck = 999;
        
        AudioSessionGetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, &overrideCategoryMixWithOthersCheckSize, &overrideCategoryMixWithOthersCheck);
        
        if(overrideCategoryMixWithOthersCheck == 1) {
            OpenEarsLog(@"OverrideCategoryMixWithOthers is correct, we will leave it as it is.");   
        } else {
            OpenEarsLog(@"OverrideCategoryMixWithOthers is incorrect, we will change it."); 
            
            UInt32 overrideCategoryMixWithOthers = 1; // Allow background sounds to mix with the session
            OSStatus overrideCategoryMixWithOthersStatus = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (overrideCategoryMixWithOthers), &overrideCategoryMixWithOthers);
            if (overrideCategoryMixWithOthersStatus != noErr) {
                OpenEarsLog(@"Error %d: Unable to set up OverrideCategoryMixWithOthers.", (int)overrideCategoryMixWithOthersStatus);
            } else {
                OpenEarsLog(@"OverrideCategoryMixWithOthers is now on the correct setting of 1.");
            }
        }    
    }
    
    UInt32 preferredBufferSizeCheckSize = sizeof (Float32);
    Float32 preferredBufferSizeCheck = 99999.9;
    
    AudioSessionGetProperty (kAudioSessionProperty_PreferredHardwareIOBufferDuration, &preferredBufferSizeCheckSize, &preferredBufferSizeCheck);

    if (fabs(preferredBufferSizeCheck - kBufferLength) < 0.0001) {
        OpenEarsLog(@"preferredBufferSize is correct, we will leave it as it is.");   
    } else {
        OpenEarsLog(@"preferredBufferSize is incorrect, we will change it."); 
    
        Float32 preferredBufferSize = kBufferLength; // apparently for best results this should be divisible by 2 so once you've found the best rate, make it even. It was previously working reliably with 1/18
        
        OSStatus preferredBufferSizeStatus = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
        if(preferredBufferSizeStatus != noErr) {
            OpenEarsLog(@"Not able to set the preferred buffer size: %d", (int)preferredBufferSizeStatus);
        } else {
            OpenEarsLog(@"PreferredBufferSize is now on the correct setting of %f.",kBufferLength);
        }
    }
    
    
 
    
    
    
    UInt32 preferredSampleRateCheckSize = sizeof (Float64);
    Float64 preferredSampleRateCheck = 99999.9;
    
    AudioSessionGetProperty (kAudioSessionProperty_PreferredHardwareSampleRate, &preferredSampleRateCheckSize, &preferredSampleRateCheck);
 
    if (fabs(preferredSampleRateCheck - kSamplesPerSecond) < 0.0001) {
        OpenEarsLog(@"preferredSampleRateCheck is correct, we will leave it as it is.");   
    } else {
        OpenEarsLog(@"preferredSampleRateCheck is incorrect, we will change it."); 
        
        Float64 preferredSampleRate = kSamplesPerSecond;
        OSStatus setPreferredHardwareSampleRate = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(preferredSampleRate), &preferredSampleRate);
        if(setPreferredHardwareSampleRate != noErr) {
            OpenEarsLog(@"Couldn't set preferred hardware sample rate: %d", (int)setPreferredHardwareSampleRate);
        } else {
            OpenEarsLog(@"preferred hardware sample rate is now on the correct setting of %f.",(Float64)kSamplesPerSecond);
        }
    }
    
#endif
    
    

}


// Here is where we're initiating the audio session.  This should only happen once in an app session.  If a second attempt is made to initiate an audio session using this class, it will hopefully

- (void) startAudioSession {
   

	OSStatus audioSessionInitializationError = AudioSessionInitialize(NULL, NULL, audioSessionInterruptionListener, NULL); // Try to initialize the audio session.
    
	if (audioSessionInitializationError !=0 && audioSessionInitializationError != kAudioSessionAlreadyInitialized) { // There was an error and it wasn't that the audio session is already initialized.
		OpenEarsLog(@"Error %d: Unable to initialize the audio session.", (int)audioSessionInitializationError);
	} else { // If there was no error we'll set the properties of the audio session now.
		
        if (audioSessionInitializationError !=0 && audioSessionInitializationError == kAudioSessionAlreadyInitialized) {
            OpenEarsLog(@"The audio session has already been initialized but we will override its properties.");
        } else {
            OpenEarsLog(@"The audio session has never been initialized so we will do that now.");
        }
        
        [self setAllAudioSessionSettings];
		
        OSStatus setAudioSessionActiveError = AudioSessionSetActive(true);  // Finally, start the audio session.
        if (setAudioSessionActiveError != 0) {
            OpenEarsLog(@"Error %d: Unable to set the audio session active.", (int)setAudioSessionActiveError);
        }
        
        //    UInt32 audioInputAvailable = 0;  // Find out if there is an available audio input. We are adding these listeners after the session has started because sometimes the category change doesn't complete before adding the listeners and the category change is heard as a route change.
        //    UInt32 size = sizeof(audioInputAvailable);
        //    OSStatus audioInputAvailableError = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &audioInputAvailable);
        //    if (audioInputAvailableError != 0) {
        //        OpenEarsLog(@"Error %d: Unable to get the availability of the audio input.", (int)audioInputAvailableError);
        //    }
        //    if(audioInputAvailableError == 0 && audioInputAvailable == 0) {
        //        OpenEarsLog(@"There is no audio input available.");
        //    }
        //    
        OSStatus addAvailabilityListenerError = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, audioSessionPropertyListener, NULL); // Create listener for changes in the Audio Session properties.
        if (addAvailabilityListenerError != 0) {
            
            OpenEarsLog(@"Error %d: Unable to add the listener for changes in input availability.", (int)addAvailabilityListenerError);
        }
        
        OSStatus audioRouteChangeListenerError = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener, NULL); // Create listener for changes in the audio route.
        if (audioRouteChangeListenerError != 0) {
            OpenEarsLog(@"Error %d: Unable to start audio route change listener.", (int)audioRouteChangeListenerError);
        }
        
		OpenEarsLog(@"AudioSessionManager startAudioSession has reached the end of the initialization.");
	}
	
	OpenEarsLog(@"Exiting startAudioSession.");

}


@end
