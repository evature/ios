//
//  Eva.m
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "Eva.h"
#import "WaveParser.h"
#import <AudioToolbox/AudioServices.h>
#import "Common.h"

#include "OpenUDID.h"
#include "wav_to_flac.h"

// New for chunked encoding
#include "FLAC/metadata.h"
#include "FLAC/stream_encoder.h"
//#include "SoundRecoder.h"
//#include "Recorder.h"
//#include "EUHTTPRequest.h"
//#include "EUHTTPResponse.h"




#define VAD_GUI_UPDATE FALSE // If you want to get the values you have to implement the delegates on Eva.h file.
/*
 // add to .h file if you set above to TRUE
 // optional - VAD debugging
 - (void)evaMicLevelCallbackMin: (float)minLevel;
 - (void)evaMicLevelCallbackMax: (float)maxLevel;
 - (void)evaMicLevelCallbackThreshold: (float)threshold;
 - (void)evaSilentMoments: (int)moments  stopOn:(float) stopMoments;
 - (void)evaNoisyMoments: (int)moments  stopOn:(float) stopMoments;
 */


#include "MOAudioStreamer.h"



//#define EVA_API_KEY @"thack-london-june-2012"
//#define EVA_SITE_CODE @"thack"

#ifdef USE_FLAC
#define USE_FLAC_TO_ENCODE TRUE//FALSE//TRUE
#define USE_CHUNKED_ENCODING TRUE
#else
#define USE_FLAC_TO_ENCODE FALSE // Should be TRUE just for crash tests
#define USE_CHUNKED_ENCODING FALSE // No implementation for Speex (yet)
#endif

// New for chunked encoding
#define BUFSIZE 512
#define Output_Buffers_To_Rewrite 3000


#define kSamplesPerSecond 16000



#define SERVER_RESPONSE_TIMEOUT 10.0f//30.0f//10.0f

#if USE_CHUNKED_ENCODING
#define LEVEL_SAMPLE_TIME 0.03f
#else
#define LEVEL_SAMPLE_TIME 0.03f
#endif

#define STOP_RECORD_AFTER_SILENT_TIME_SEC 0.7f//1.0f

#define MIC_RECORD_TIMEOUT_DEFAULT 8.0f//15.0f//8.0f

#define EVA_HOST_ADDRESS @"https://vproxy.evaws.com:443"//@"https://ec2-54-235-35-62.compute-1.amazonaws.com:443"//@"https://vproxy.evaws.com:443"

@interface Eva ()<AVAudioRecorderDelegate,CLLocationManagerDelegate
,RecorderDelegate // new for isRecorderReady
#if !SYSTEM_SOUND
,AVAudioPlayerDelegate
#endif
//SoundRecoderDelegate

//,EUHTTPRequestDelegate
//,EUHTTPResponseDelegate
//,NSStreamDelegate
,MOAudioStreamerDeelegate
>{
    float latitude,longitude;
    
    BOOL startIsPressed;
    
    NSTimer *levelTimer;
    
    double lowPassResults;
    double lowPassResultsPeak;
    
    double minVolume;
    
    BOOL sendMicLevel;
    
    NSInteger silentMoments;
    NSInteger noisyMoments;
    NSInteger totalMomements;
    
    BOOL startSilenceDetection;
    
    float micRecordTimeout;
    
    BOOL recordHasBeenCanceled;
    
    // For chunked encoding
    /* BOOL isPlaying;
     AudioQueueRef outputQueue;
     FLAC__StreamEncoder *encoder;
     AudioQueueBufferRef buffers[Output_Buffers_To_Rewrite]; */
    
    //SoundRecoder *_recorder;
    
    //    Recorder *_recorder;
    
    //NSString *language;
    
    // NSData *streamOfData;
    
    //    NSInputStream *iStream;
    //    NSOutputStream *oStream;
    
    //    BOOL finished;
    
    MOAudioStreamer *streamer;
    
    //ChunkTransfer *chunkTransferContainer;
    
#if SYSTEM_SOUND
    // optional - audio files to play before or after recording the user - set to NULL to skip playing those sounds.
    SystemSoundID audioFileStartRecord;
    SystemSoundID audioFileRequestedEndRecord;
    SystemSoundID audioFileVadEndRecord;
    SystemSoundID audioFileCanceledRecord;
#else
    AVAudioPlayer *audioFileStartRecord;
    AVAudioPlayer *audioFileRequestedEndRecord;
    AVAudioPlayer *audioFileVadEndRecord;
    AVAudioPlayer *audioFileCanceledRecord;
#endif
    
}



//@property(nonatomic) NSInteger amount;

// For audio recording (wav) recording //
@property(retain,nonatomic) AVAudioRecorder *recorder;

@property(retain,nonatomic) MOAudioStreamer *streamer;
//@property(nonatomic) AVAudioRecorder *recorder;
@property(retain,nonatomic) NSURL * wavFileUrl;

@property(nonatomic,retain) NSMutableData * responseData;
@property(nonatomic,retain) NSURLConnection * connection;
@property(nonatomic,retain) NSString *ipAddress;
@property(nonatomic,retain) CLLocationManager *locationManager;

@property(nonatomic,retain) NSString *sessionID;

@property(nonatomic,retain) NSString *evaAPIKey;
@property(nonatomic,retain) NSString *evaSiteCode;

@property(nonatomic,retain) NSTimer *audioTimeoutTimer;

@property(nonatomic) BOOL sendMicLevel;

@property(nonatomic) float micRecordTimeout;

@property(nonatomic,retain) NSString *language;
//@property (nonatomic, weak) id <EvaDelegate> delegate;

@property(nonatomic) BOOL isPlaying;
@property(nonatomic) AudioQueueRef outputQueue;
@property(nonatomic) FLAC__StreamEncoder *encoder;
//@property(nonatomic) AudioQueueBufferRef buffers[Output_Buffers_To_Rewrite];

//@property(retain,nonatomic) NSData* streamOfData;

//@property (nonatomic, strong) NSInputStream *iStream;
//@property (nonatomic, strong) NSOutputStream *oStream;

//@property(nonatomic,retain) ChunkTransfer *chunkTransferContainer;

//@property(nonatomic,retain) IBOutlet UILabel *outputLabel;

#if SYSTEM_SOUND
@property(nonatomic) SystemSoundID audioFileStartRecord;
@property(nonatomic) SystemSoundID audioFileRequestedEndRecord;
@property(nonatomic) SystemSoundID audioFileVadEndRecord;
@property(nonatomic) SystemSoundID audioFileCanceledRecord;
#else
@property(nonatomic, retain) AVAudioPlayer *audioFileStartRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileRequestedEndRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileVadEndRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileCanceledRecord;
#endif


@end

@implementation Eva
//@synthesize amount = amount_;
@synthesize recorder = recorder_;
@synthesize wavFileUrl = wavFileUrl_;

@synthesize responseData = responseData_;
@synthesize connection = connection_;
@synthesize ipAddress = ipAddress_;
@synthesize locationManager = locationManager_;

@synthesize delegate = delegate_;
@synthesize sessionID = sessionID_;

@synthesize evaAPIKey = evaAPIKey_;
@synthesize evaSiteCode = evaSiteCode_;
@synthesize uid= uid_;

@synthesize bias = bias_;
@synthesize home = home_;
@synthesize language = language_;

@synthesize scope = scope_;
@synthesize context = context_;
@synthesize optional_dictionary = optional_dictionary_;

@synthesize audioTimeoutTimer = audioTimeoutTimer_;

@synthesize version = version_;
@synthesize sendMicLevel = sendMicLevel_;

@synthesize micRecordTimeout = micRecordTimeout_;

@synthesize isPlaying=isPlaying_;
@synthesize outputQueue=outputQueue_;
@synthesize encoder=encoder_;

//@synthesize streamOfData = streamOfData_;

@synthesize streamer=streamer_;


@synthesize audioFileStartRecord = audioFileStartRecord_;
@synthesize audioFileRequestedEndRecord = audioFileRequestedEndRecord_;
@synthesize audioFileVadEndRecord = audioFileVadEndRecord_;
@synthesize audioFileCanceledRecord = audioFileCanceledRecord_;

//@synthesize iStream = _iStream;
//@synthesize oStream = _oStream;
//@synthesize chunkTransferContainer = _chunkTransferContainer;




+ (Eva *)sharedInstance
{
    static Eva *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[Eva alloc] init];
	}
	return sharedInstance;
}


// URL optional dictionary //
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


- (NSString*)urlSafeEncodedOptionalParametersString {
    NSMutableArray *parts = [NSMutableArray array];
    NSDictionary *dict = [optional_dictionary_ mutableCopy];
    for (id key in dict) {
        id value = [dict objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [self makeSafeString:urlEncode(key)],[self makeSafeString: urlEncode(value)]];
        [parts addObject: part];
    }
    dict = nil;
    return [parts componentsJoinedByString: @"&"];
}


#if SYSTEM_SOUND
static BOOL setAudio(NSString* tag, SystemSoundID* soundObj, NSURL* filePath) {
#else
static BOOL setAudio(NSString* tag, AVAudioPlayer** soundObj, NSURL* filePath) {
#endif
    if (filePath == NULL) {
        NSLog(@"set %@: to NULL", tag);
        *soundObj = 0;
    }
    else {
#if SYSTEM_SOUND
        if (*soundObj != 0) {
            AudioServicesDisposeSystemSoundID(*soundObj);
        }
        // Create a system sound object representing the sound file.
        OSStatus errorCode = AudioServicesCreateSystemSoundID ((__bridge CFURLRef)filePath, soundObj );
        NSLog(@"set %@: filePath: %@,  errorCode: %ld", tag, filePath, errorCode);
        if (errorCode != 0) {
            NSLog(@"ERROR %ld: Failed to initialize %@ audio file %@", errorCode, tag, filePath);
            *soundObj = 0;
            return FALSE;
        }
#else
        // Create AVAudioPlayer for the audio file
        NSError *error;
        *soundObj = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
        NSLog(@"set %@: filePath: %@", tag, filePath);
        if (error != nil) {
            NSLog(@"Error setting player");
            *soundObj = nil;
            return FALSE;
        }
        else {
            [*soundObj setVolume:1.0];
            [*soundObj prepareToPlay];
        }
#endif
        
    }
    return TRUE;
}



- (void) startActualRecording {
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [self recordToFile];
     
     });*/
#if USE_CHUNKED_ENCODING
    [self startRecordQueue];
#else
    [self recordToFile];
#endif
    
    [locationManager_ startUpdatingLocation];

    
    startIsPressed = TRUE;
    lowPassResultsPeak = 0; // initiate the peak.
    //#if !USE_CHUNKED_ENCODING
    audioTimeoutTimer_=[NSTimer scheduledTimerWithTimeInterval:micRecordTimeout_//8.0
                                                        target:self
                                                      selector:@selector(stopRecordOnTick:)
                                                      userInfo:nil
                                                       repeats:NO];
    
    silentMoments = 0;
    noisyMoments = 0;
    totalMomements = 0;
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: LEVEL_SAMPLE_TIME target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];

    //#endif
}

#if SYSTEM_SOUND
void startRecordSystemSoundCompletionProc (SystemSoundID  ssID, void *clientData) {
    [[Eva sharedInstance] startActualRecording];
}
#else
    
    - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
        if (player == audioFileStartRecord_) {
            [[Eva sharedInstance] startActualRecording];
        }
    }
#endif


// External API functions //


// this sound will play when a "startRecord" method is called - the actual recording will start after the sound finishes playing
- (BOOL) setStartRecordAudioFile: (NSURL *)filePath {
#if SYSTEM_SOUND
    if (audioFileStartRecord_ != 0) {
        AudioServicesRemoveSystemSoundCompletion(audioFileStartRecord_);
        audioFileStartRecord_ = 0;
    }
    BOOL result = setAudio(@"StartRecord", &audioFileStartRecord_, filePath);
    if (result) {
        AudioServicesAddSystemSoundCompletion(audioFileStartRecord_,
                                              NULL,
                                              NULL,
                                              startRecordSystemSoundCompletionProc,
                                              NULL);
    }
#else
    
    if (audioFileStartRecord_ != 0) {
        audioFileStartRecord_.delegate = nil;
        audioFileStartRecord_ = 0;
    }
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"StartRecord", &temp, filePath);
    audioFileStartRecord_ = temp;
    if (result) {
        audioFileStartRecord_.delegate = self;
    }
#endif
    return result;
}

// this sound will play when the "stopRecord" is called
- (BOOL) setRequestedEndRecordAudioFile: (NSURL *)filePath {
#if SYSTEM_SOUND
    return setAudio(@"RequestedEndRecord", &audioFileRequestedEndRecord_, filePath);
#else
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"RequestEndRecord", &temp, filePath);
    audioFileRequestedEndRecord_ = temp;
    return result;
#endif
}

// this sound will play when the VAD (voice activity detection) recognizes the user finished speaking
- (BOOL) setVADEndRecordAudioFile: (NSURL *)filePath {
#if SYSTEM_SOUND
    return setAudio(@"VADEndRecord", &audioFileVadEndRecord_, filePath);
#else

    AVAudioPlayer *temp;
    BOOL result = setAudio(@"VADEndRecord", &temp, filePath);
    audioFileVadEndRecord_ = temp;
    return result;
#endif
}

// this sound will play when calling "cancelRecord"
- (BOOL) setCanceledRecordAudioFile: (NSURL *)filePath {
#if SYSTEM_SOUND
    return setAudio(@"CanceledRecord", &audioFileCanceledRecord_, filePath);
#else

    AVAudioPlayer *temp;
    BOOL result = setAudio(@"CanceledRecord", &temp, filePath);
    audioFileCanceledRecord_ = temp;
    return result;
#endif
}


- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code{
    //  NSLog(@"Eva.framework version %@(%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
    
    NSLog(@"Eva.framework version v%@",EVA_FRAMEWORK_VERSION);
    
    evaAPIKey_ = [NSString stringWithFormat:@"%@", api_key];
    evaSiteCode_ = [NSString stringWithFormat:@"%@", site_code];
    
    if    (DEBUG_MODE_FOR_EVA){
        NSLog(@"It's debug mode");
        if (USE_FLAC_TO_ENCODE) {
            NSLog(@"Using FLAC for the encoding process - For iOS 7.0.3 test");
        }
    }
    startIsPressed = FALSE;
    
    sendMicLevel_ = FALSE;
    
    //isPlaying = NO;
    
    micRecordTimeout_ = MIC_RECORD_TIMEOUT_DEFAULT;
    
#if USE_CHUNKED_ENCODING
    //[self initAudioQueue]; // New for chunked encoding
#else
    [self initRecordFile]; // New - Less time?
#endif
    
    [self initLocationManager]; // Init the location manager  (takes some time)
    // - unfortunately can't be in dispatch because must be with run loop
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //ipAddress_ = [self getIPAddress];
        //[self getCurrenLocale];
#if DEBUG_LOGS
        NSLog(@"Dispatch #1");
#endif
        [Recorder sharedInstance].delegate = self; ///// NEEWWWWWWW /////
       // // start a record and stop it immidiately after
        [[Recorder sharedInstance] startRecording:TRUE];
       
#if DEBUG_LOGS
        NSLog(@"Dispatch #2");
#endif
        ipAddress_ = [self getIPAddress];
        [self getCurrenLocale];
#if DEBUG_LOGS
        NSLog(@"Dispatch #3");
#endif
        
        
    });
    
    
    return TRUE;
}

- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel{
    [self setAPIkey:api_key withSiteCode:site_code];
    
    sendMicLevel_ = shouldSendMicLevel;  // ********** SHOULD BE ON SOME INIT function ***********
    
    
    return TRUE;
}

- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel withRecordingTimeout:(float)secToTimeout{
    [self setAPIkey:api_key withSiteCode:site_code withMicLevel:shouldSendMicLevel];
    
    if (secToTimeout>SERVER_RESPONSE_TIMEOUT) {
        micRecordTimeout_ = SERVER_RESPONSE_TIMEOUT;
    }else{
        micRecordTimeout_ = secToTimeout;
    }
    
    return TRUE;
}

- (BOOL)startRecordNoSession{
    return [self startRecord:FALSE orNoSession:TRUE];
}

- (BOOL)startRecord:(BOOL)withNewSession{
    return [self startRecord:withNewSession orNoSession:FALSE];

}

- (BOOL)startRecord:(BOOL)withNewSession orNoSession:(BOOL)noSession{
#if DEBUG_LOGS
    NSLog(@"Start recording");
#endif
    recordHasBeenCanceled = FALSE;
    
    minVolume = DBL_MAX; // Iftach addon
    
    startSilenceDetection = FALSE;
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE;
    }
    
    if (![[Recorder sharedInstance] isRecorderReady]) { // New to check if record is ready
        NSLog(@"Eva: Recorder isn't ready yet");
        return FALSE; // Should be commented? (it would fail the record if not commented)
    }
    
    
    if (noSession) {
        sessionID_ = nil;
    }else if (withNewSession) {
        sessionID_ = [NSString stringWithFormat:@"1"];
    }

    
    if (audioFileStartRecord_ != 0) {
        // start "beep" sound -
        // the audio completion callback will trigger the actual recording
#if SYSTEM_SOUND
        SYSTEM_SOUND_FUNCTION(audioFileStartRecord_);
#else
        [audioFileStartRecord_ play];
#endif
    }
    else {
        // no sound - trigger the recording here
        [self startActualRecording];
    }
            
    return TRUE;
    
}

- (BOOL)stopRecord{
    return [self stopRecord:FALSE];
}

- (BOOL)stopRecord: (BOOL)fromVad{
#if DEBUG_LOGS
    NSLog(@"Stop recording");
#endif
    
    [audioTimeoutTimer_ invalidate];
    audioTimeoutTimer_ = nil;
    if (startIsPressed) {
        if (fromVad) {
            if (audioFileVadEndRecord_ != 0) {
#if SYSTEM_SOUND
                SYSTEM_SOUND_FUNCTION(audioFileVadEndRecord_);
#else
                [audioFileVadEndRecord_ play];
#endif
            }
        }
        else {
            if (audioFileRequestedEndRecord_ != 0) {
#if SYSTEM_SOUND
                SYSTEM_SOUND_FUNCTION(audioFileRequestedEndRecord_);
#else
                [audioFileRequestedEndRecord_ play];
#endif
            }
        }
#if USE_CHUNKED_ENCODING
        // Call the stop queue function
        [self stopRecordQueue];
#else
        [self stopRecordingToFile];
#endif
        [locationManager_ stopUpdatingLocation];
        
        startIsPressed = FALSE;
        if (sendMicLevel_) {
            if([[self delegate] respondsToSelector:@selector(evaMicStopRecording)]){
                
                [[self delegate] evaMicStopRecording];
            }else{
                NSLog(@"Eva-Critical Error: You haven't implemented evaMicStopRecording, It is a must with your settings. Please implement this one");
            }
        }
        
        return TRUE;
    }else{
        if    (DEBUG_MODE_FOR_EVA){
            NSLog(@"Eva: Must initiate a startRecord before using stopRecord method");
        }
        return FALSE;
    }
}

- (BOOL)cancelRecord{
#if DEBUG_LOGS
    NSLog(@"Cancel recording");
#endif
    if (audioFileCanceledRecord_ != 0) {
#if SYSTEM_SOUND
        SYSTEM_SOUND_FUNCTION(audioFileCanceledRecord_);
#else
        [audioFileCanceledRecord_ play];
#endif
    }
    
    recordHasBeenCanceled = TRUE;
    
    return [self stopRecord];
    
    
}

-(void)stopRecordOnTick:(NSTimer *)timer {
    [self stopRecord];
}

-(NSURL *)recWavFileURL{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
    NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"rec.wav" //@"rec.m4a"//m4a"
                                                ]];
    return tmpFileUrl;
    
    
}

#pragma mark -

#pragma mark - SRWebSocketDelegate methods





#pragma mark AudioRecordings


-(void)dataSend:(void*)data withLength: (unsigned) len{
#if DEBUG_LOGS
    NSLog(@"dataSend:withLength, Length = %d",len);
#endif
    //streamOfData_ = [NSData dataWithBytes:data length:len];
    
    // NSUInteger bytesWritten = [self.oStream write:(const uint8_t)[(__bridge NSData *)data bytes] maxLength:[(__bridge NSData *)data length]];
    
    // NSLog(@"Written %d bytes to buffer",bytesWritten);
    // if (bytesWritten == len) {
    
    // }
    
    /*   if ([ChunkTransfer sharedInstance]==nil) {
     return;
     }
     
     ChunkTransfer *transfer = [ChunkTransfer sharedInstance];//= (uint8_t *)data;
     
     if (transfer.dataBuffer==nil) {
     //transfer.dataBuffer = [NSMutableData dataWithBytes:data length:len ];
     
     transfer.dataBuffer = [NSMutableData dataWithCapacity:8192];
     }
     
     if (transfer.dataQueue == nil) {
     transfer.dataQueue = [[NSMutableArray alloc] initWithCapacity:10];
     }
     
     if (len>0)
     {
     int length = len*2;
     @synchronized(transfer)
     {
     NSLog(@"@synchronized(transfer)");
     if (transfer.dataBuffer == nil)
     transfer.dataBuffer = [NSMutableData dataWithCapacity:8192];
     
     [transfer.dataBuffer appendData:[NSData dataWithBytes:data
     length:length]];
     NSLog(@"transfer.dataBuffer.length = %d",transfer.dataBuffer.length);
     
     if (transfer.dataBuffer.length >= 4096)
     {
     [transfer.dataQueue addObject:transfer.dataBuffer];
     transfer.dataBuffer = nil;
     NSLog(@"transfer.dataQueue.count = %d",transfer.dataQueue.count);
     }
     
     if (transfer.oStream.hasSpaceAvailable) {
     NSLog(@" ***** transfer.oStream.hasSpaceAvailable ***** , transfer.dataBuffer.length = %d, transfer.dataQueue.count = %d",transfer.dataBuffer.length, transfer.dataQueue.count);
     }
     
     if (transfer.oStream.hasSpaceAvailable && transfer.dataQueue.count){
     [transfer sendNextChunk];
     }
     }
     }
     else
     {
     [transfer sendEndChunkAndCloseStream];
     }
     */
    return ;
    
    
}

-(void)establishConnectionOnTick:(NSTimer *)timer {
    [self establishConnection];
}

-(void)initAudioQueue{
    /* streamOfData_ = [[NSData alloc] init]; // NEW.
     
     _recorder = [[Recorder alloc] init];//[[SoundRecoder alloc] init];
     _recorder.delegate = self;*/
}

-(void)startRecordQueue{
    /* NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
     NSString *savePath = [documentDir stringByAppendingPathComponent:@"rec.flac"];
     //_recorder.delegate = self;
     //[_recorder startRecording:savePath];
     [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil]; // NEw for testing recorder. Isn't necessary.
     //[_recorder init];
     
     [self initAudioQueue];
     
     [self establishConnection]; // New for checking Chunked encoding
     
     
     [_recorder startRecording];*/
    lowPassResultsPeak = 0; // initiate the peak.
    silentMoments = 0;
    
    //recordHasBeenCanceled = FALSE;
    
    //startSilenceDetection = FALSE;

    
    
#if DEBUG_LOGS
    NSLog(@"PPPP A1");
#endif
    [self establishConnection];
    //[[MOAudioStreamer sharedInstance] startStreamer];
#if DEBUG_LOGS
    NSLog(@"PPPP A2");
#endif
    [streamer_ startStreamer];
#if DEBUG_LOGS
    NSLog(@"PPPP A3");
#endif
    
}

-(void)stopRecordQueue{
    [levelTimer invalidate];
    levelTimer = nil;
    
    
    /*   if (_recorder != nil)
     {
     [_recorder stopRecording];
     //[_recorder release];
     _recorder = nil;
     } */
    
    
    
    if (recordHasBeenCanceled) {
        [streamer_ cancelStreaming];
    }else{
        [streamer_ stopStreaming];
    }
    //[[ChunkTransfer sharedInstance] sendEndChunkAndCloseStream]; // ------- TEMP ----------- //
    //streamer_ = nil; // NEW - 10/9/13
    
}

/*-(void)soundRecoderDidFinishRecording:(SoundRecoder *)recoder{
 NSLog(@"soundRecoderDidFinishRecording");
 recoder.delegate = nil;
 //[self establishConnection]; // Commentes for real chunked encoding stuff
 
 
 
 //[self performSelectorInBackground:@selector(makeRecognitionRequest:) withObject:recoder.savedPath];
 }*/

#pragma mark Recorder
-(void)recorderIsReady{
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Got Signal : recorderIsReady");
#endif

    if([[self delegate] respondsToSelector:@selector(evaRecorderIsReady)]){
        
        [[self delegate] evaRecorderIsReady];
    }else{
        NSLog(@"Eva-Warning: You haven't implemented evaRecorderIsReady, It's only optional but you may want to implement this one");
    }
}


#pragma mark MOAudioStreamer

-(void)MOAudioStreamerDidFinishStreaming:(MOAudioStreamer*)streamer
{
#if DEBUG_LOGS
    NSLog(@"AudioStreamerDidFinishStreaming");
#endif
}

-(void)MOAudioStreamerDidFinishRequest:(NSURLConnection*)connectionRequest withResponse:(NSString*)response
{
#if DEBUG_LOGS
    NSLog(@"AudioStreamerDidFinishRequest");
#endif
    
}

-(void)MOAudioStreamerDidFailed:(MOAudioStreamer*)streamer message:(NSString*)reason
{
#if DEBUG_LOGS
    NSLog(@"AudioStreamerDidFailed - %@", reason);
#endif
}

- (void)MOAudioStreamerConnection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    [self connection:theConnection didReceiveResponse:response];
    
}
- (void)MOAudioStreamerConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    [self connection:theConnection didReceiveData:data];
    
}
- (void)MOAudioStreamerConnection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    [self connection:theConnection didFailWithError:error];
    
}
- (void)MOAudioStreamerConnectionDidFinishLoading:(NSURLConnection *)theConnection{
    [self connectionDidFinishLoading:theConnection];
    
}

- (void)MORecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
#if DEBUG_LOGS
    NSLog(@"MORecorderMicLevelCallbackAverage");
#endif
    [self recorderMicLevelCallbackAverage:averagePower andPeak:peakPower];
}



#pragma mark -
#pragma mark Record to file handlers

-(void)initRecordFile{
    
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
    NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"rec.wav" //@"rec.m4a"//m4a"
                                                ]];
    wavFileUrl_ = tmpFileUrl;
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
#if USE_FLAC_TO_ENCODE
    [recordSettings setValue:[NSNumber numberWithFloat:16000.0
                              ] forKey:AVSampleRateKey];
#else
    [recordSettings setValue:[NSNumber numberWithFloat:41000.0//16000.0
                              ] forKey:AVSampleRateKey];
#endif
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    //[recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    // New settings below //
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithInt:16//8
                              ] forKey: AVLinearPCMBitDepthKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey: AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithBool:NO] forKey: AVLinearPCMIsBigEndianKey];
    [recordSettings setValue:[NSNumber numberWithBool:NO] forKey: AVLinearPCMIsFloatKey];
    [recordSettings setValue:[NSNumber numberWithInt: AVAudioQualityLow] forKey: AVEncoderAudioQualityKey];
    
    
    NSError *error = nil;
    //AVAudioRecorder *recorder
    recorder_ = [[AVAudioRecorder alloc] initWithURL:wavFileUrl_//tmpFileUrl
                                            settings:recordSettings error:&error
                 ];
    
    //recordSettings = nil;
    //[recordSettings removeAllObjects]; // NEW
    //prepare to record
    [recorder_ setDelegate:self];
    
    // [recorder_ prepareToRecord];
    //recorder_.meteringEnabled = YES;
    
    [recorder_ prepareToRecord];
    recorder_.meteringEnabled = YES;
    
    
    //[recorder prepareToRecord];
    
    NSLog(@"Setting session to AVAudioSessionCategoryRecord");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    if ([session respondsToSelector:@selector(setCategory:withOptions:error:)]) { // Using iOS 6+
        [session setCategory:AVAudioSessionCategoryRecord error:nil];
    }else{
        // Do somthing smart for iOS 5 //
    }
    
    [session setActive:YES error:nil];
    
#if DEBUG_MODE_FOR_EVA
    BOOL audioHWAvailable = session.inputIsAvailable;
    if (! audioHWAvailable) {
#if DEBUG_LOGS
        NSLog(@"ERROR: Audio input hardware not available");
#endif
        
    }else{
#if DEBUG_LOGS
        NSLog(@"Audio input hardware available! ");
#endif
    }
#endif
    
    
}

-(void)recordToFile{
    
    // [self initLocationManager]; // NEW // // This makes a lot of time to capture.
    
    //[locationManager startUpdatingLocation];
    
    // [self userIsTalking];
    
    //askForStopRecording = FALSE;
    
    // NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"test.spx"]];
    
    /*    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
     NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"rec.wav" //@"rec.m4a"//m4a"
     ]];
     wavFileUrl_ = tmpFileUrl;
     
     NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
     
     [recordSettings setValue:[NSNumber numberWithFloat:41000.0//16000.0
     ] forKey:AVSampleRateKey];
     [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
     
     //[recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
     // New settings below //
     [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
     [recordSettings setValue:[NSNumber numberWithInt:16//8
     ] forKey: AVLinearPCMBitDepthKey];
     [recordSettings setValue:[NSNumber numberWithInt: 1] forKey: AVNumberOfChannelsKey];
     [recordSettings setValue:[NSNumber numberWithBool:NO] forKey: AVLinearPCMIsBigEndianKey];
     [recordSettings setValue:[NSNumber numberWithBool:NO] forKey: AVLinearPCMIsFloatKey];
     [recordSettings setValue:[NSNumber numberWithInt: AVAudioQualityLow] forKey: AVEncoderAudioQualityKey];
     
     
     NSError *error = nil;
     //AVAudioRecorder *recorder
     recorder_ = [[AVAudioRecorder alloc] initWithURL:wavFileUrl_//tmpFileUrl
     settings:recordSettings error:&error];
     
     //prepare to record
     [recorder_ setDelegate:self];
     
     [recorder_ prepareToRecord];
     recorder_.meteringEnabled = YES;
     
     
     //[recorder prepareToRecord];
     
     AVAudioSession *session = [AVAudioSession sharedInstance];
     [session setCategory:AVAudioSessionCategoryRecord error:nil];
     [session setActive:YES error:nil];*/
    
    
    
    [recorder_ record];
    
    //levelTimer = [NSTimer scheduledTimerWithTimeInterval: LEVEL_SAMPLE_TIME target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    //silentMoments = 0;
    
}



- (void)recorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{

#if DEBUG_LOGS
    NSLog(@"recorderMicLevelCallbackAverage:andPeak");
#endif
    /*  const double ALPHA = 0.05;
     double peakPowerForChannel = pow(10, (0.05 * averagePower));
     lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
     
     #if DEBUG_MODE_FOR_EVA
     //NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder_ averagePowerForChannel:0], [recorder_ peakPowerForChannel:0], lowPassResults);
     #endif
     
     if (sendMicLevel_){
     if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackAverage:andPeak:)]){
     
     [[self delegate] evaMicLevelCallbackAverage:averagePower andPeak:peakPower];
     }else{
     NSLog(@"Eva-Critical Error: You haven't implemented evaMicLevelCallbackAverage:andPeak, It is a must with your settings. Please implement this one");
     }
     
     
     }
     
     if (lowPassResults > 0.5//0.1
     ){
     startSilenceDetection = TRUE;
     
     }
     if (startSilenceDetection) {
     // New code for VAD to detect voice on noisy environment //
     if (lowPassResults>lowPassResultsPeak) { // Take new peak
     lowPassResultsPeak = lowPassResults;
     silentMoments = 0;
     }
     #if DEBUG_MODE_FOR_EVA
     NSLog(@"lowPassResultsPeak = %f",lowPassResultsPeak);
     #endif
     
     //if (lowPassResults < 0.05){
     if (lowPassResults < lowPassResultsPeak /2 ) { // detecting difference from peak and not from constant
     
     silentMoments++;
     #if DEBUG_MODE_FOR_EVA
     NSLog(@"Mic silent detected num: %d",silentMoments);
     #endif
     }else{
     silentMoments = 0;
     }
     if (silentMoments >= STOP_RECORD_AFTER_SILENT_TIME_SEC/LEVEL_SAMPLE_TIME ) {
     #if DEBUG_MODE_FOR_EVA
     NSLog(@"Silent: Can stop record");
     #endif
     [self stopRecordQueue];
     }
     }
     */
    
}


/*- (void)levelTimerCallback:(NSTimer *)timer {
    
    
#if USE_CHUNKED_ENCODING
    double peakPower = [streamer_ peakPower];
    double averagePower = [streamer_ averagePower];
#else
    [recorder_ updateMeters];
    double peakPower = [recorder_ peakPowerForChannel:0];
    double averagePower = [recorder_ averagePowerForChannel:0];
#endif
    
    
    const double ALPHA = 0.25; //0.05;
	double peakPowerForChannel = pow(10, (0.05 * peakPower));
    if (peakPowerForChannel < minVolume) { // Iftach addon
        minVolume = peakPowerForChannel;
    }
    
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
#if DEBUG_MODE_FOR_EVA
    //	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", averagePower, peakPower, lowPassResults);
#endif
    
    if (sendMicLevel_){
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackAverage:andPeak:)]){
            
            [[self delegate] evaMicLevelCallbackAverage:averagePower andPeak:peakPower];
        }else{
            NSLog(@"Eva-Critical Error: You haven't implemented evaMicLevelCallbackAverage:andPeak, It is a must with your settings. Please implement this one");
        }
        
        
    }
    
    if (lowPassResults > 0.5//0.1
        ){
        startSilenceDetection = TRUE;
        
    }
    if (startSilenceDetection) {
        // New code for VAD to detect voice on noisy environment //
        if (lowPassResults>lowPassResultsPeak) { // Take new peak
            lowPassResultsPeak = lowPassResults;
            silentMoments = 0;
        }
        #if DEBUG_MODE_FOR_EVA
                NSLog(@"lowPassResultsPeak = %f",lowPassResultsPeak);
        #endif
        
        
        //if (lowPassResults < lowPassResultsPeak /2 ) { // detecting difference from peak and not from constant
        if ((lowPassResults-minVolume) < 0.2*(lowPassResultsPeak-minVolume) ) { // Iftach logic
            
            silentMoments++;
#if DEBUG_MODE_FOR_EVA
            NSLog(@"Mic silent detected num: %d",silentMoments);
#endif
        }else{
            silentMoments = 0;
        }
        if (silentMoments >= STOP_RECORD_AFTER_SILENT_TIME_SEC/LEVEL_SAMPLE_TIME ) {
#if DEBUG_MODE_FOR_EVA
            NSLog(@"Silent: Can stop record");
#endif
            [self stopRecord];
        }
    }
}*/

- (void)levelTimerCallback:(NSTimer *)timer {
	
   // double startTime =  CACurrentMediaTime();
    totalMomements++;
    
#if USE_CHUNKED_ENCODING
    double peakPower = [streamer_ peakPower];
    double averagePower = [streamer_ averagePower];
#else
    [recorder_ updateMeters];
    double peakPower = [recorder_ peakPowerForChannel:0];
    double averagePower = [recorder_ averagePowerForChannel:0];
#endif
    
    //    const double ALPHA = 0.25;
    const double MIN_NOISE_TIME = 0.10;  // must have noise for at least this much time to start considering VAD silence
    const double PRE_VAD_RECORDING_TIME = 0.12; // VAD will start listening to noise/silence only after this time
	double currentPowerForChannel = pow(10, (0.05 * averagePower));
    
    lowPassResults = currentPowerForChannel;
	//lowPassResults = ALPHA * currentPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    if (lowPassResults < minVolume) {
        minVolume = lowPassResults;
#if VAD_GUI_UPDATE
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackMin:)]){
            [[self delegate] evaMicLevelCallbackMin:minVolume];
        }
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackThreshold:)]){
            [[self delegate] evaMicLevelCallbackThreshold:  0.2*(lowPassResultsPeak-minVolume) + minVolume ];
        }
#endif
    }
    
    if (lowPassResults>lowPassResultsPeak) { // Take new peak
        lowPassResultsPeak = lowPassResults;
        silentMoments = 0;
#if VAD_GUI_UPDATE
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackMax:)]){
            [[self delegate] evaMicLevelCallbackMax: lowPassResultsPeak];
        }
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackThreshold:)]){
            [[self delegate] evaMicLevelCallbackThreshold:  0.2*(lowPassResultsPeak-minVolume) + minVolume ];
        }
        if([[self delegate] respondsToSelector:@selector(evaSilentMoments:stopOn:)]){
            [[self delegate] evaSilentMoments: silentMoments stopOn:(STOP_RECORD_AFTER_SILENT_TIME_SEC/LEVEL_SAMPLE_TIME)];
        }
#endif
    }
    
    if (sendMicLevel_){
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackAverage:andPeak:)]){
            [[self delegate] evaMicLevelCallbackAverage:averagePower andPeak:peakPower];
        }else{
            NSLog(@"Eva-Critical Error: You haven't implemented evaMicLevelCallbackAverage:andPeak, It is a must with your settings. Please implement this one");
        }
    }
    
    if (!startSilenceDetection && totalMomements > (PRE_VAD_RECORDING_TIME/LEVEL_SAMPLE_TIME)) {
        if (lowPassResults >  MIN(10* minVolume, 0.8)
            ){
            noisyMoments++;
            if (noisyMoments >= MIN_NOISE_TIME/LEVEL_SAMPLE_TIME) {
                startSilenceDetection = TRUE;
            }
        }
        else {
            noisyMoments = 0;
        }
#if VAD_GUI_UPDATE
        if([[self delegate] respondsToSelector:@selector(evaNoisyMoments:stopOn:)]){
            [[self delegate] evaNoisyMoments: noisyMoments stopOn:(MIN_NOISE_TIME/LEVEL_SAMPLE_TIME)];
        }
#endif
    }
    
    // not using "else" here because the flag could be just set to true in the previous 'if' block
    if (startSilenceDetection) {
        
        if ((lowPassResults-minVolume) < 0.2*(lowPassResultsPeak-minVolume) ) {
            silentMoments++;
        }else{
            silentMoments = 0;
        }
#if VAD_GUI_UPDATE
        if([[self delegate] respondsToSelector:@selector(evaSilentMoments:stopOn:)]){
            [[self delegate] evaSilentMoments: silentMoments stopOn:(STOP_RECORD_AFTER_SILENT_TIME_SEC/LEVEL_SAMPLE_TIME) ];
        }
#endif
        
        if (silentMoments >= STOP_RECORD_AFTER_SILENT_TIME_SEC/LEVEL_SAMPLE_TIME ) {
#if DEBUG_MODE_FOR_EVA
            NSLog(@"Silent: Can stop record");
#endif
            [self stopRecord:TRUE];
        }
    }
    
    //double delta = CACurrentMediaTime() - startTime;
    //NSLog(@"===> VAD processed in %.3f", delta);
    //if (delta > 0.03 ) {
    //    NSLog(@"\n\n!!!!!!!!! too slow !!!!!!!!\n\n");
   // }
}

-(void)stopRecordingToFile{
    
    
    [recorder_ stop];
    
    [levelTimer invalidate];
    levelTimer = nil;
    
    NSLog(@"Stopping session");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    int flags = AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation;
    [session setActive:NO withFlags:flags error:nil];
    
    
    
    //[locationManager stopUpdatingLocation];
    
    //stopRecording(audioDevice);   // Stop.
    //closeAudioDevice(audioDevice);
    //askForStopRecording = TRUE;
    
    //[self userStoppedTalking];
    
    //[self evaIsWriting];
    
    //[self stopSiriEffect];
    
    //[self establishConnection];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
#if DEBUG_LOGS
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
#endif
    // your actions here
    if (flag) {
        if (!recordHasBeenCanceled) {
#if USE_FLAC_TO_ENCODE
            [self convertFileToFLAC];
#else
#endif
        }
        
    }else{
       
        NSLog(@"There is a problem with recording");
    }
    
    //[self establishConnection];
    
}

#pragma mark - FLAC Handler

-(void)convertFileToFLAC{
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"convertFileToFLAC");
    
    NSLog(@"wavFileUrl_ : %@", wavFileUrl_);//waveFilePath);
    
    NSLog(@"[wavFileUrl_ absoluteString]=%@", [wavFileUrl_ absoluteString]);
#endif
    
    NSURL *someURL = wavFileUrl_; // some file URL
    NSString *path = [someURL path];
    //NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path];
    
    NSString* expandedPath = [path stringByExpandingTildeInPath];
    
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[documentPath objectAtIndex:0]]; // Get documents directory
    
    NSString *flacOutputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"rec"];
    
    
    
    //NSError *encodingError;
    
    NSString *flacFileWithoutExtension = flacOutputFile;//path to the output file
    NSString *waveFile = expandedPath; //path to the wave input file
    int interval_seconds = 30;
    char** flac_files = (char**) malloc(sizeof(char*) * 1024);
    
    int conversionResult = Eva_convertWavToFlac([waveFile UTF8String], [flacFileWithoutExtension UTF8String], interval_seconds, flac_files);
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Flac: conversionResult = %d",conversionResult);
#endif
    
    
    
    
    
    
    
    if (!conversionResult) { // success //
        // Send to Eva
        [self establishConnection];
    }else{
        NSLog(@"There was an error with flac encoding");
    }
}



- (NSString *)makeSafeString:(NSString *)inString{
    
#if USE_SAFE_STRING
    NSString *unsafeString = [NSString stringWithFormat:@"%@",inString];//@"this &string= confuses ? the InTeRwEbZ";
    CFStringRef safeURLString = CFURLCreateStringByAddingPercentEscapes (
                                                                         NULL,
                                                                         (CFStringRef)unsafeString,
                                                                         NULL,
                                                                         CFSTR("/%?&=-$#+~@<>|\\*,.()[]{}^!"),
                                                                         kCFStringEncodingUTF8
                                                                         );
    
    NSString* safeReturnString= [NSString stringWithFormat:@"%@",safeURLString];
    CFRelease(safeURLString);
    return safeReturnString;
#else
    return inString;
#endif
}
- (NSString *)makeSafeStringVersion:(NSString *)inString{
    
#if USE_SAFE_STRING
    NSString *unsafeString = [NSString stringWithFormat:@"%@",inString];//@"this &string= confuses ? the InTeRwEbZ";
    CFStringRef safeURLString = CFURLCreateStringByAddingPercentEscapes (
                                                                         NULL,
                                                                         (CFStringRef)unsafeString,
                                                                         NULL,
                                                                         CFSTR("/%?&=-$#+~@<>|\\*,()[]{}^!"),
                                                                         kCFStringEncodingUTF8
                                                                         );
    
    NSString* safeReturnString= [NSString stringWithFormat:@"%@",safeURLString];
    CFRelease(safeURLString);
    return safeReturnString;
#else
    return inString;
#endif
}

- (NSString *)makeSafeStringUID:(NSString *)inString{
    
#if USE_SAFE_STRING
    NSString *unsafeString = [NSString stringWithFormat:@"%@",inString];//@"this &string= confuses ? the InTeRwEbZ";
    CFStringRef safeURLString = CFURLCreateStringByAddingPercentEscapes (
                                                                         NULL,
                                                                         (CFStringRef)unsafeString,
                                                                         NULL,
                                                                         CFSTR("/%?&=$#+~@<>|\\*.,()[]{}^!"),
                                                                         kCFStringEncodingUTF8
                                                                         );
    
    NSString* safeReturnString= [NSString stringWithFormat:@"%@",safeURLString];
    CFRelease(safeURLString);
    return safeReturnString;
#else
    return inString;
#endif
}

-(NSString *) URLEncodeString:(NSString *) str // New to fix 7.0.3 issue //
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Connection with Eva server

-(void)establishConnection{
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"***** getUID =,%@, *****",[self getUID]); // For test
    NSLog(@"Current time zone=,%@, Locale=,%@,",[self getCurrentTimezone],[self getCurrenLocale]);
#endif
    
    NSURL *url;
    

    if (version_ != nil) {
        url = [NSURL URLWithString:[self URLEncodeString:[NSString stringWithFormat:@"%@/%@?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@",EVA_HOST_ADDRESS,[self makeSafeStringVersion:version_],evaSiteCode_,evaAPIKey_,[self getCurrenLocale],[self getCurrentTimezone],//sessionID_, //&session_id=%@
                                    [self getUID]]]];
        
    }else{
        url = [NSURL URLWithString:[self URLEncodeString:[NSString stringWithFormat:@"%@/v1.0?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@",EVA_HOST_ADDRESS,evaSiteCode_,evaAPIKey_,[self getCurrenLocale],[self getCurrentTimezone],//sessionID_,
                                    [self getUID]]]];
    }
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Version Url = %@",url);
#endif
    //url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vproxy.evaws.com:443/?site_code=%@&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&session_id=%@&uid=%@",evaSiteCode_,evaAPIKey_,ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],sessionID_,[self getUID]]];
    
    if (longitude==0 && latitude ==0) { // Check if location services returned a valid value
        
    }else{          // There are GPS coordinates
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&latitude=%.5f&longitude=%.5f",url,latitude,longitude]];
        
        //url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vproxy.evaws.com:443/?site_code=thack&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&latitude=%.5f&longitude=%.5f",@"thack-london-june-2012",ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],latitude,longitude]];
    }
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Long&Lat Url = %@",url);
#endif
    
    if (sessionID_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&session_id=%@",url,sessionID_]];
    }
    if (ipAddress_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&ip_addr=%@",url,ipAddress_]];
    }
    
    
    if (bias_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&bias=%@",url,[self makeSafeString:bias_]]];
    }
    if (home_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&home=%@",url,[self makeSafeString:home_]]];
    }
    if (language_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&language=%@",url,language_]];
    }
    if (scope_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&scope=%@",url,[self makeSafeString:scope_]]];
    }
    if (context_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&context=%@",url,[self makeSafeString:context_]]];
    }
    
    if (optional_dictionary_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",url,[self urlSafeEncodedOptionalParametersString]]];
    }
    
    // Add version number to URL (new from version 1.4.6) //
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&sdk_version=ios-%@",url,EVA_FRAMEWORK_VERSION]];
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Url = %@",url);
   // NSLog(@"safeUrl = %@",safeURLString);
#endif
    
#if TESTFLIGHT_TESTING
    TFLog(@"urlToEva:%@",url);
#endif
    
   
    self.responseData = [[NSMutableData alloc] initWithLength:0] ;
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:SERVER_RESPONSE_TIMEOUT];  // New : Set timeout...
    
    [request setHTTPMethod:@"POST"];
    
    // "Content-Type: audio/x-speex;rate=16000"
#if USE_FLAC_TO_ENCODE
    NSString *headerBoundary = [NSString stringWithFormat:@"audio/x-flac;rate=%d",16000];//41000];
#else
    NSString *headerBoundary = [NSString stringWithFormat:@"audio/x-speex;rate=%d",kSamplesPerSecond];
#endif
    
    // set header
    [request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
#if !USE_CHUNKED_ENCODING
    //Accept-Language: ENUS
    [request addValue:@"ENUS" forHTTPHeaderField:@"Accept-Language"];
    
    // "Accept-Topic: Dictation"
    
    [request addValue:@"Dictation" forHTTPHeaderField:@"Accept-Topic"];
    
    // "Accept: text/plain"
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];
#endif
    
    //"Transfer-Encoding: chunked"
    ///// Removed to test on iOS 5 //
    
#if USE_CHUNKED_ENCODING
    [request addValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
    
    //NSOutputStream *dataStream = [NSOutputStream outputStreamWithURL:<#(NSURL *)#> append:<#(BOOL)#>:streamOfData_];
    /* NSInputStream *dataStream = [[NSInputStream alloc] initWithData:streamOfData_];
     
     
     EUHTTPRequest* streamRequest = [[EUHTTPRequest alloc] initWithInputStream:dataStream delegate:self];
     
     [streamRequest run];
     
     
     
     [request setHTTPBodyStream:[streamRequest inputStream]];//dataStream];*/
    
    
    
    //_chunkTransferContainer = [ChunkTransfer alloc];
    /*if ([[ChunkTransfer sharedInstance] initWithURL:url withRequest:request andConnection:connection_]) {
     NSLog(@"ChunkTransfer object init success");
     }else{
     NSLog(@"ChunkTransfer object init unsuccess");
     };
     
     self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self.superclass // superclass is new
     startImmediately:NO]; // Was yes before chunked
     
     // NSString *runloopmode = [[NSRunLoop currentRunLoop] currentMode];
     // [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runloopmode];
     
     
     [self.connection start];*/
    
    streamer_ = [MOAudioStreamer new];//[[MOAudioStreamer alloc] init];
    
    //NSString *url = [NSString stringWithFormat:@"%@/%@?site_code=%@&api_key=%@",GOOGLE_API_URL,@"v1.0",@"thack",@"thack-london-june-2012"];
    //NSLog(@"URL: %@",url);
    streamer_.webServiceURL = [NSString stringWithFormat:@"%@",url];//@"http://www.google.com/speech-api/v1/recognize";
    
    //NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]];
    streamer_.recordingPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES)[0];
    //NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    
    streamer_.fileToSaveName = @"rec";
    streamer_.streamerDelegate = self;
    
    /* [MOAudioStreamer sharedInstance].webServiceURL = [NSString stringWithFormat:@"%@",url];//@"http://www.google.com/speech-api/v1/recognize";
     
     
     [MOAudioStreamer sharedInstance].recordingPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES)[0];
     //NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
     
     [MOAudioStreamer sharedInstance].fileToSaveName = @"rec";
     [MOAudioStreamer sharedInstance].streamerDelegate = self;*/
    
    
    
    
    
    
    
    

#else
    
    NSMutableData *postBody = [NSMutableData data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
#if USE_FLAC_TO_ENCODE
    NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"rec.flac"]];
#else
    NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"rec.spx"]];
#endif
    
    
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)[soundData length]]   forHTTPHeaderField:@"content-length"]; // For ios 5 test
    
    [postBody appendData:soundData];
    [postBody appendData:[@"\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
    
    // final boundary
    //[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add body to post
    [request setHTTPBody:postBody];
    
    //#endif  // Chunked encoding
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES]; // Was yes before chunked
    //self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES]; // Was yes before chunked
#endif
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // You may have received an HTTP 200 here, or not...
#if DEBUG_LOGS
    NSLog(@"didReceiveResponse");
#endif
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        //If you need the response, you can use it here
        // NEW Code - Send error code if no data on body and good response with code //
        int code = [httpResponse statusCode];
        if (code>=400) {
            [[self delegate] evaDidFailWithError:[NSError errorWithCode:code]];
        }
        
        // End of new code //
        
#if DEBUG_MODE_FOR_EVA
        NSLog(@"httpResponse = %@",[httpResponse description]);
        NSLog(@"Response code = %d",code);
#endif
        
        
        
        // NSLog(@"httpResponse MIME = %@",[[httpResponse ] lowercaseString]);
    }
    
    [responseData_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    
    
    
    
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
#if DEBUG_MODE_FOR_EVA
    NSLog(@"This is my first chunk %@", aStr);
#endif
    
#if TESTFLIGHT_TESTING
    TFLog(@"JSon Reply:%@",aStr);
#endif
    
    // [[NSUserDefaults standardUserDefaults] setValue:aStr forKey:kLastJsonStringFromEva ];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
#if DEBUG_MODE_FOR_EVA
    NSLog(@"input_text=%@",[json objectForKey:@"input_text"]);
    
    NSDictionary* apiReply = [json objectForKey:@"api_reply"]; //2
    //NSDictionary* locationsReply = [apiReply objectForKey:@"Locations"];
    if ([apiReply respondsToSelector:@selector(objectForKey:)]//apiReply!=NULL
        ) {
        NSString *sayIt = [apiReply objectForKey:@"Say It"];
        NSString *processedText = [apiReply objectForKey:@"ProcessedText"];
        
        //[outputLabel setText:sayIt];
        NSLog(@"SayIt=%@, ProcessedText=%@",sayIt,processedText);
    }
    
    // [self userSay:processedText];
    // [self evaSay:sayIt];
    
    // [self stopSiriEffect];
    //curViewState = kEvaWaitingForUserPress;
#endif
    if ([json respondsToSelector:@selector(objectForKey:)]) {
#if DEBUG_MODE_FOR_EVA
        NSLog(@"[json respondsToSelector:@selector(objectForKey:)] == TRUE");
#endif
        sessionID_ = [NSString stringWithFormat:@"%@", [json objectForKey:@"session_id"]];
        if (sessionID_ == nil) {
            [NSString stringWithFormat:@"1"];
        }
    }
    
    if([[self delegate] respondsToSelector:@selector(evaDidReceiveData:)]){
        
        [[self delegate] evaDidReceiveData:data];
    }else{
        NSLog(@"Eva-Critical Error: You haven't implemented evaDidReceiveData:, It is a must! Please implement this one");
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connectionV {
    // [connection2 release];
    connectionV = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Eva: Something went wrong...");
    
    if([[self delegate] respondsToSelector:@selector(evaDidFailWithError:)]){
        
        [[self delegate] evaDidFailWithError:error];
    }else{
        NSLog(@"Eva-Critical Error: You haven't implemented evaDidFailWithError:, It is a must! Please implement this one");
    }
    
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Error from Eva: %@",[error description]);
#endif
    // [self evaSay:@"Something went wrong, Please try again"];
    
    // [self stopSiriEffect];
    // curViewState = kEvaWaitingForUserPress;
}

#pragma mark - MISC user info (Location etc.)

-(void)initLocationManager{
    
    locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.delegate = self;
    locationManager_.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager_.desiredAccuracy = kCLLocationAccuracyKilometer;//
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    if (fabs(longitude - newLocation.coordinate.longitude) > 0.05 ||
        fabs(latitude - newLocation.coordinate.latitude) > 0.05) {
#if DEBUG_LOGS
        NSLog(@"Lat&Long: %.5f %.5f", //fabs(
              newLocation.coordinate.latitude
              //)
              , //fabs(
              newLocation.coordinate.longitude
              //)
              );
#endif
        longitude = newLocation.coordinate.longitude;
        latitude = newLocation.coordinate.latitude;
    }
}


-(NSString *)getCurrentTimezone{
    NSInteger hoursFromGMT = [[NSTimeZone defaultTimeZone] secondsFromGMT]/3600;
    NSInteger minutesFromGMT = (([[NSTimeZone defaultTimeZone] secondsFromGMT]+0)%3600)/60;
    //NSLog(@"Timezone=%d",[[NSTimeZone defaultTimeZone] secondsFromGMT]/3600);
    
    if (hoursFromGMT>=0) {
        return [NSString stringWithFormat:@"+%02d:%02d",hoursFromGMT,minutesFromGMT];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d",hoursFromGMT,minutesFromGMT];
    }
}

-(NSString *)getCurrenLocale{
    NSLocale* currentLocale = [NSLocale currentLocale];

#if DEBUG_LOGS
    NSLog(@"Locale = %@", [currentLocale objectForKey:NSLocaleCountryCode]);
#endif
    return [currentLocale objectForKey:NSLocaleCountryCode];
}

- (NSString *)getIPAddress
{
    NSUInteger  an_Integer;
    NSArray * ipItemsArray;
    NSString *externalIP;
    
    NSURL *iPURL = [NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"];
    
    if (iPURL) {
        NSError *error = nil;
#if DEBUG_LOGS
        NSLog(@"Getting IP Addr");
#endif
        NSString *theIpHtml = [NSString stringWithContentsOfURL:iPURL
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (!error) {
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray =[theIpHtml  componentsSeparatedByString:@" "];
                an_Integer=[ipItemsArray indexOfObject:@"Address:"];
                
                externalIP =[ipItemsArray objectAtIndex:  ++an_Integer];
                
                
            }
            
#if DEBUG_LOGS
            NSLog(@"IP_ADDR: %@",externalIP);
#endif
            return [NSString stringWithFormat:@"%@",externalIP];
        } else {
#if DEBUG_LOGS
            NSLog(@"Oops... failed to get IpAddr:  %d, %@",
                  [error code],
                  [error localizedDescription]);
#endif
        }
    }
    
    
    
    
    //[pool drain];
    return @"";
}

#pragma mark - MISC for url parameters
-(NSString *)getUID{
    if (uid_!=nil) {  // User set a uid.
        return [self makeSafeStringUID:uid_];
    }else if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        // This is will run if it is iOS6
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        // This is will run before iOS6 and you can use openUDID or other
        // method to generate an identifier
        return [Eva_OpenUDID value];//@"iOS-5-test-UID";//[[[UIDevice currentDevice] uniqueIdentifier] description]; // Check if that won't crash on iOS5
        
        
    }
    
    
}



@end
