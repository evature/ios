//  OpenEars version 1.0
//  http://www.politepix.com/openears
//
//  AudioConstants.h
//  OpenEars
// 
//  AudioConstants is a class which sets constants controlling audio behavior that are used in many places in the API. To control the ringbuffer, it's sufficient to interact with kBufferLength only.
//
//  Copyright Politepix UG (haftungsbeschränkt) 2012. All rights reserved.
//  http://www.politepix.com
//  Contact at http://www.politepix.com/contact
//
//  This file is licensed under the Politepix Shared Source license found in the root of the source distribution.

//#import "OpenEarsConfig.h"

#define kSamplesPerSecond 16000 //8000
#define kBitsPerChannel 16
#define kBufferLength .128 // This is the size of the audio unit buffer in seconds. Not as short as Audio Units can be, but we need a fairly large chunk of samples for the read function or it will be difficult for the ringbuffer to stay ahead of it.

#define kPredictedSizeOfRenderFramesPerCallbackRound kBufferLength * kSamplesPerSecond // This is the expected number of frames per callback
#define kMaxFrames kPredictedSizeOfRenderFramesPerCallbackRound * 4 // Let's cap the max frames allowed at 4x the expected frames so weird circumstances don't overrun the buffers

#define kNumberOfChunksInRingbuffer 14 // How many sections the ringbuffer has
#define kChunkSizeInBytes kPredictedSizeOfRenderFramesPerCallbackRound * 5 // The size of an individual section, which is the predicted callback size * 5 to allow the maximum allowed frames and a little extra


#define kLowPassFilterTimeSlice .001 // For calculating decibel levels
#define kDBOffset -120.0 // This is the negative offset for calculating decibel levels


//#define SPEEXLOGGING // Uncomment for debugging

#ifdef SPEEXLOGGING // With thanks to Marcus Zarra.
#	define OpenEarsLog(fmt, ...) NSLog((@"SPEEXLOGGING: " fmt), ##__VA_ARGS__);
#else
#	define OpenEarsLog(...)
#endif