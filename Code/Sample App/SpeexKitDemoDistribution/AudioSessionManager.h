//  OpenEars version 1.0
//  http://www.politepix.com/openears
//
//  AudioSessionManager.h
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

//  This class creates an Audio Session for your app which uses OpenEars, and forwards important notification about
//  Audio Session status changes to OpenEarsEventsObserver.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 
#import "AudioConstants.h"

@interface AudioSessionManager : NSObject {
    BOOL soundMixing;
}

@property(nonatomic, assign) BOOL soundMixing; // This lets background sounds like iPod music and alerts play during your app session (also likely to cause those elements to be recognized by an active Pocketsphinx decoder, so only set this to true after initializing your audio session if you know you want this for some reason.)

-(void) startAudioSession; // All that we need to access from outside of this class is the method to start the Audio Session.

@end
