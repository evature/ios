//
//  Eva.m
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "Eva.h"
#import <AudioToolbox/AudioServices.h>
#import "Common.h"

#include "OpenUDID.h"

#include "FLAC/metadata.h"
#include "FLAC/stream_encoder.h"




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




#define SERVER_RESPONSE_TIMEOUT 10.0f//30.0f//10.0f

#define LEVEL_SAMPLE_TIME 0.03f

#define STOP_RECORD_AFTER_SILENT_TIME_SEC 0.7f//1.0f

#define MIC_RECORD_TIMEOUT_DEFAULT 8.0f//15.0f//8.0f

#define EVA_HOST_ADDRESS @"https://vproxy.evaws.com:443"//@"https://ec2-54-235-35-62.compute-1.amazonaws.com:443"//@"https://vproxy.evaws.com:443"
#define EVA_HOST_ADDRESS_FOR_TEXT  @"http://apiuseh.evaws.com"

@interface Eva ()<
AVAudioRecorderDelegate,
CLLocationManagerDelegate
,RecorderDelegate // for isRecorderReady
,AVAudioPlayerDelegate
,MOAudioStreamerDelegate
,NSURLConnectionDelegate
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
    
    // For chunked encoding
    MOAudioStreamer *streamer;
    

    AVAudioPlayer *audioFileStartRecord;
    AVAudioPlayer *audioFileRequestedEndRecord;
    AVAudioPlayer *audioFileVadEndRecord;
    AVAudioPlayer *audioFileCanceledRecord;
    
}



//@property(nonatomic) NSInteger amount;

// For audio recording (wav) recording //
@property(retain,nonatomic) MOAudioStreamer *streamer;

@property(nonatomic,retain) NSMutableData * responseData; // collect the current response
@property(nonatomic,retain) NSURLConnection * connection; // the current connection to Eva
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


@property(nonatomic, retain) AVAudioPlayer *audioFileStartRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileRequestedEndRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileVadEndRecord;
@property(nonatomic, retain) AVAudioPlayer *audioFileCanceledRecord;


@end

@implementation Eva

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


static BOOL setAudio(NSString* tag, AVAudioPlayer** soundObj, NSURL* filePath) {
    if (filePath == NULL) {
        NSLog(@"set %@: to NULL", tag);
        *soundObj = 0;
    }
    else {
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
    }
    return TRUE;
}



- (void) startActualRecording {
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [self recordToFile];
     
     });*/
    [self startRecordQueue];
    
    [locationManager_ startUpdatingLocation];

#if DEBUG_LOGS
    NSLog(@"Starting actual recording");
#endif
    startIsPressed = TRUE;
    lowPassResultsPeak = 0; // initiate the peak.
    audioTimeoutTimer_=[NSTimer scheduledTimerWithTimeInterval:micRecordTimeout_//8.0
                                                        target:self
                                                      selector:@selector(stopRecordOnTick:)
                                                      userInfo:nil
                                                       repeats:NO];
    
    silentMoments = 0;
    noisyMoments = 0;
    totalMomements = 0;
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: LEVEL_SAMPLE_TIME target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player == audioFileStartRecord_) {
       [[Eva sharedInstance] startActualRecording];
    }
}


// External API functions //


// this sound will play when a "startRecord" method is called - the actual recording will start after the sound finishes playing
- (BOOL) setStartRecordAudioFile: (NSURL *)filePath {
   
    if (audioFileStartRecord_ != nil) {
        audioFileStartRecord_.delegate = nil;
        audioFileStartRecord_ = nil;
    }
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"StartRecord", &temp, filePath);
    audioFileStartRecord_ = temp;
    if (result) {
        audioFileStartRecord_.delegate = self;
    }
    return result;
}

// this sound will play when the "stopRecord" is called
- (BOOL) setRequestedEndRecordAudioFile: (NSURL *)filePath {
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"RequestEndRecord", &temp, filePath);
    audioFileRequestedEndRecord_ = temp;
    return result;
}

// this sound will play when the VAD (voice activity detection) recognizes the user finished speaking
- (BOOL) setVADEndRecordAudioFile: (NSURL *)filePath {
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"VADEndRecord", &temp, filePath);
    audioFileVadEndRecord_ = temp;
    return result;
}

// this sound will play when calling "cancelRecord"
- (BOOL) setCanceledRecordAudioFile: (NSURL *)filePath {
    AVAudioPlayer *temp;
    BOOL result = setAudio(@"CanceledRecord", &temp, filePath);
    audioFileCanceledRecord_ = temp;
    return result;
}


- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code{
    //  NSLog(@"Eva.framework version %@(%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
    
    NSLog(@"Eva.framework version v%@",EVA_FRAMEWORK_VERSION);
    
    evaAPIKey_ = [NSString stringWithFormat:@"%@", api_key];
    evaSiteCode_ = [NSString stringWithFormat:@"%@", site_code];
    
    if    (DEBUG_MODE_FOR_EVA){
        NSLog(@"It's debug mode");
    }
#if DEBUG_LOGS
    NSLog(@"setAPIKey startIsPressed=FALSE");
#endif
    startIsPressed = FALSE;
    
    sendMicLevel_ = FALSE;
    
    //isPlaying = NO;
    
    micRecordTimeout_ = MIC_RECORD_TIMEOUT_DEFAULT;
    
    
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
    if (delegate_ == nil) {
        NSLog(@"Eva: delegate is nil - please set delegate before starting a recording");
        return FALSE;
    }
    
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE;
    }
    
    if (![[Recorder sharedInstance] isRecorderReady]) { // New to check if record is ready
        NSLog(@"Eva: Recorder isn't ready yet");
        return FALSE; // Should be commented? (it would fail the record if not commented)
    }
    
    
    if (noSession) {
        [self setNoSession];
    }else if (withNewSession || sessionID_ == nil) {
        [self setNewSession];
    }

    return [self startRecord];
    
}

- (BOOL)stopRecord{
    return [self stopRecord:FALSE wasCanceled:FALSE];
}

- (BOOL)stopRecord: (BOOL)fromVad  wasCanceled:(BOOL)wasCanceled{
#if DEBUG_LOGS
    NSLog(@"Stop recording");
#endif
    
    [audioTimeoutTimer_ invalidate];
    audioTimeoutTimer_ = nil;
    if (startIsPressed) {
        if (!wasCanceled) {
            if (fromVad) {
                if (audioFileVadEndRecord_ != nil) {
                    [audioFileVadEndRecord_ play];
                }
            }
            else {
                if (audioFileRequestedEndRecord_ != nil) {
                    [audioFileRequestedEndRecord_ play];
                }
            }
        }
        // Call the stop queue function
        [self stopRecordQueue: wasCanceled];
        [locationManager_ stopUpdatingLocation];
#if DEBUG_LOGS
        NSLog(@"stopped recording - set startIsPressed to False");
#endif
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
    if (audioFileCanceledRecord_ != nil) {
        [audioFileCanceledRecord_ play];
    }
    
    
    BOOL result = [self stopRecord:FALSE wasCanceled:TRUE];

    // note: stop record may fail if cancel is called after the request is complete (and therefore the recording is already stopped)
    // but the response may still arrive soon - setting the streamer_ to nil will allow us to ignore the response
    streamer_ = nil;
    
    return result;
}



// query Eva by text - optional start new session
- (BOOL)queryWithText:(NSString *)text startNewSession:(BOOL)newSession {
    if (delegate_ == nil) {
        NSLog(@"Eva: delegate is nil - please set delegate before starting a text search");
        return FALSE;
    }
    
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE;
    }
    
    if (newSession || sessionID_ == nil) {
        [self setNewSession];
    }
        
    return [self queryWithText:text];
}

/*

// Get Session id - useful for debugging
// nil = no session
// 1 = new session
// other = an active session of this id
- (NSString *)getSessionId {
    return sessionID_;
}
*/

// alternative API - session control using its own methods
- (void)setNewSession {
#if DEBUG_LOGS
    NSLog(@"Starting new session");
#endif
    sessionID_ = [NSString stringWithFormat:@"1"];
    /*
    if([[self delegate] respondsToSelector:@selector(evaNewSessionWasStarted:)]){
        [[self delegate] evaNewSessionWasStarted:true];
    }*/
}

- (void)setNoSession {
#if DEBUG_LOGS
    NSLog(@"Setting to no-session");
#endif
    sessionID_ = nil;
}

// query with Text or voice - continues active session if any
- (BOOL)queryWithText:(NSString *)text {
    if (delegate_ == nil) {
        NSLog(@"Eva: delegate is nil - please set delegate before starting a text search");
        return FALSE;
    }
    
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE;
    }
    
    if (streamer_ != nil) {
        [self stopRecord:FALSE wasCanceled:TRUE];
        streamer_ = nil;
    }

    NSURL *url = [self getUrl:EVA_HOST_ADDRESS_FOR_TEXT];

    NSString *safeText = [self URLEncodeString:text];
#if DEBUG_MODE_FOR_EVA
    NSLog(@"SafeText = %@",safeText);
#endif
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&input_text=%@", url, safeText]];
    
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Url = %@",url);
#endif

    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return TRUE;
}

- (BOOL)startRecord {

    if (delegate_ == nil) {
        NSLog(@"Eva: delegate is nil - please set delegate before starting a recording");
        return FALSE;
    }
    
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE;
    }
    
    if (![[Recorder sharedInstance] isRecorderReady]) { // New to check if record is ready
        NSLog(@"Eva: Recorder isn't ready yet");
        return FALSE; // Should be commented? (it would fail the record if not commented)
    }

    minVolume = DBL_MAX;
    startSilenceDetection = FALSE;
    
    if (audioFileStartRecord_ != nil) {
        // start "beep" sound -
        // the audio completion callback will trigger the actual recording
        [audioFileStartRecord_ play];
    }
    else {
        // no sound - trigger the recording here
        [self startActualRecording];
    }
    return TRUE;
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

-(void)startRecordQueue{
    
    lowPassResultsPeak = 0; // initiate the peak.
    silentMoments = 0;
    
    DLog(@"Dbg:  startRecordQueue");
    [self establishConnection];
    //[[MOAudioStreamer sharedInstance] startStreamer];
    DLog(@"Dbg:  established connection, starting streamer");
    [streamer_ startStreamer];
    DLog(@"Dbg: Streamer started");
    
}

-(void)stopRecordQueue: (BOOL)wasCanceled{
    [levelTimer invalidate];
    levelTimer = nil;
    
    
    /*   if (_recorder != nil)
     {
     [_recorder stopRecording];
     //[_recorder release];
     _recorder = nil;
     } */
    
    
    
    if (wasCanceled) {
        [streamer_ cancelStreaming];
        streamer_ = nil;
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

-(void)MOAudioStreamerDidFinishStreaming:(MOAudioStreamer*)theStreamer
{
#if DEBUG_LOGS
    NSLog(@"Streamer: AudioStreamerDidFinishStreaming");
#endif
}

-(void)MOAudioStreamerDidFinishRequest:(MOAudioStreamer*)theStreamer theConnection:(NSURLConnection*)connectionRequest withResponse:(NSString*)response
{
#if DEBUG_LOGS
    NSLog(@"Streamer: AudioStreamerDidFinishRequest");
#endif
    
}

-(void)MOAudioStreamerDidFailed:(MOAudioStreamer*)theStreamer message:(NSString*)reason
{
#if DEBUG_LOGS
    NSLog(@"Streamer: AudioStreamerDidFailed - %@", reason);
#endif
}

- (void)MOAudioStreamerConnection:(MOAudioStreamer*)theStreamer theConnection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    if (theStreamer == streamer_) {
        connection_ = theConnection;
        [self connection:theConnection didReceiveResponse:response];
#if DEBUG_LOGS
        NSLog(@"Streamer: didReceiveResponse");
    }
    else {
        NSLog(@"Streamer: didReceiveResponse - ignored");
#endif
    }
}
- (void)MOAudioStreamerConnection:(MOAudioStreamer*)theStreamer theConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    if (theStreamer == streamer_) {
        [self connection:theConnection didReceiveData:data];
#if DEBUG_LOGS
        NSLog(@"Streamer: didReceiveData");
    }
    else {
        NSLog(@"Streamer: didReceiveData - ignored");
#endif
    }
}
- (void)MOAudioStreamerConnection:(MOAudioStreamer*)theStreamer theConnection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    if (theStreamer == streamer_) {
        [self connection:theConnection didFailWithError:error];
#if DEBUG_LOGS
        NSLog(@"Streamer: didFailWithError");
    }
    else {
        NSLog(@"Streamer: didFailWithError - ignored");
#endif
    }
}
- (void)MOAudioStreamerConnectionDidFinishLoading:(MOAudioStreamer*)theStreamer theConnection:(NSURLConnection *)theConnection{
    if (theStreamer == streamer_) {
        [self connectionDidFinishLoading:theConnection];
#if DEBUG_LOGS
        NSLog(@"Streamer: DidFinishLoading");
    }
    else {
        NSLog(@"Streamer: DidFinishLoading - ignored");
#endif
    }
}

- (void)MORecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
#if DEBUG_LOGS
    NSLog(@"MORecorderMicLevelCallbackAverage");
#endif
    [self recorderMicLevelCallbackAverage:averagePower andPeak:peakPower];
}





- (void)recorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{

#if DEBUG_LOGS
    NSLog(@"recorderMicLevelCallbackAverage:andPeak");
#endif
    
}


- (void)levelTimerCallback:(NSTimer *)timer {
	
    if ([self delegate] == nil) {
        NSLog(@"Eva: delegate is nil - the recording will now stop");
        [self cancelRecord];
        return;
    }
    
   // double startTime =  CACurrentMediaTime();
    totalMomements++;
    
    double peakPower = [streamer_ peakPower];
    double averagePower = [streamer_ averagePower];
    
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
            [self stopRecord:TRUE wasCanceled:FALSE];
        }
    }
    
    //double delta = CACurrentMediaTime() - startTime;
    //NSLog(@"===> VAD processed in %.3f", delta);
    //if (delta > 0.03 ) {
    //    NSLog(@"\n\n!!!!!!!!! too slow !!!!!!!!\n\n");
   // }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
#if DEBUG_LOGS
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
#endif
    // your actions here
    if (!flag) {
        
        NSLog(@"There is a problem with recording");
    }
    
    //[self establishConnection];
    
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

-(NSURL *)getUrl:(NSString *)host {
    
    NSURL *url;
    
    if (version_ != nil) {
        url = [NSURL URLWithString:[self URLEncodeString:[NSString stringWithFormat:@"%@/%@?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@",host,[self makeSafeStringVersion:version_],evaSiteCode_,evaAPIKey_,[self getCurrenLocale],[self getCurrentTimezone],//sessionID_, //&session_id=%@
                                                          [self getUID]]]];
        
    }else{
        url = [NSURL URLWithString:[self URLEncodeString:[NSString stringWithFormat:@"%@/v1.0?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@",host,evaSiteCode_,evaAPIKey_,[self getCurrenLocale],[self getCurrentTimezone],//sessionID_,
                                                          [self getUID]]]];
    }
    
    
    if (longitude==0 && latitude ==0) { // Check if location services returned a valid value
        
    }else{          // There are GPS coordinates
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&latitude=%.5f&longitude=%.5f",url,latitude,longitude]];
    }
    
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
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&device=%@&ios_ver=%@", url, [UIDevice currentDevice].model, [[UIDevice currentDevice] systemVersion]]];
    
    // Add version number to URL (new from version 1.4.6) //
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&sdk_version=ios-%@",url,EVA_FRAMEWORK_VERSION]];
    
    return url;
    
}

-(void)establishConnection{
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"***** getUID =,%@, *****",[self getUID]); // For test
    NSLog(@"Current time zone=,%@, Locale=,%@,",[self getCurrentTimezone],[self getCurrenLocale]);
#endif
    
    NSURL *url = [self getUrl: EVA_HOST_ADDRESS];
    

#if DEBUG_MODE_FOR_EVA
    NSLog(@"Url = %@",url);
   // NSLog(@"safeUrl = %@",safeURLString);
#endif
    
#if TESTFLIGHT_TESTING
    TFLog(@"urlToEva:%@",url);
#endif
    
   
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:SERVER_RESPONSE_TIMEOUT];  // New : Set timeout...
    
    [request setHTTPMethod:@"POST"];
    
    NSString *headerBoundary = [NSString stringWithFormat:@"audio/x-flac;rate=%d",16000];
    
    // set header
    [request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    
    
    streamer_ = [MOAudioStreamer new];//[[MOAudioStreamer alloc] init];
    
    streamer_.webServiceURL = [NSString stringWithFormat:@"%@",url];//@"http://www.google.com/speech-api/v1/recognize";
    
    streamer_.recordingPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES)[0];
    
    streamer_.fileToSaveName = @"rec";
    streamer_.streamerDelegate = self;
    
}







#pragma mark NSURLConnection Delegate Methods
// based on http://codewithchris.com/tutorial-how-to-use-ios-nsurlconnection-by-example/#asynchronous



- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // You may have received an HTTP 200 here, or not...
#if DEBUG_LOGS
    NSLog(@"didReceiveResponse");
#endif
    
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData_ = [[NSMutableData alloc] init];

    
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
        
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection != connection_) {
#if DEBUG_MODE_FOR_EVA
        NSLog(@"didReceiveData for wrong connection");
#endif
        return;
    }
    
    // Append the new data to the instance variable you declared
    [responseData_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection != connection_) {
        #if DEBUG_MODE_FOR_EVA
        NSLog(@"Did finish loading for wrong connection");
        #endif
        return;
    }
    #if DEBUG_MODE_FOR_EVA
    NSLog(@"Did finish loading");
    #endif    
    
#if TESTFLIGHT_TESTING
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    TFLog(@"JSon Reply:%@",aStr);
#endif
    
    // [[NSUserDefaults standardUserDefaults] setValue:aStr forKey:kLastJsonStringFromEva ];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData_
                          
                          options:kNilOptions
                          error:&error];
#if DEBUG_MODE_FOR_EVA
    NSLog(@"input_text=%@",[json objectForKey:@"input_text"]);
    
    NSDictionary* apiReply = [json objectForKey:@"api_reply"]; //2
    //NSDictionary* locationsReply = [apiReply objectForKey:@"Locations"];
    if ([apiReply respondsToSelector:@selector(objectForKey:)]//apiReply!=NULL
        ) {
        NSString *sayIt = [apiReply objectForKey:@"SayIt"];
        NSString *processedText = [apiReply objectForKey:@"ProcessedText"];
        
        //[outputLabel setText:sayIt];
        NSLog(@"SayIt=%@, ProcessedText=%@",sayIt,processedText);
    }
    
#endif
    
    if ([json respondsToSelector:@selector(objectForKey:)]) {
        NSString *newSessionId = [NSString stringWithFormat:@"%@", [json objectForKey:@"session_id"]];
        /*if (sessionID_ != nil && newSessionId != nil && ![sessionID_ isEqualToString:@"1"] && ![sessionID_ isEqualToString:newSessionId]) {
            // was not nil and not 1, and changed - a new session was started
            if([[self delegate] respondsToSelector:@selector(evaNewSessionWasStarted:)]){
                [[self delegate] evaNewSessionWasStarted:false];
            }
        }*/
        sessionID_ = newSessionId;
        if (sessionID_ == nil) {
            sessionID_ = [NSString stringWithFormat:@"1"];
        }
        NSLog(@"SessionId set to %@", sessionID_);
    }
    
    if([[self delegate] respondsToSelector:@selector(evaDidReceiveData:)]){
        
        [[self delegate] evaDidReceiveData:responseData_];
    }else{
        NSLog(@"Eva-Critical Error: You haven't implemented evaDidReceiveData:, It is a must! Please implement this one");
    }
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection != connection_) {
        return;
    }
    // The request has failed for some reason!
    // Check the error var
   
    NSLog(@"Error from Eva: %@",[error description]);

    if([[self delegate] respondsToSelector:@selector(evaDidFailWithError:)]){
        
        [[self delegate] evaDidFailWithError:error];
    }else{
        NSLog(@"Eva-Critical Error: You haven't implemented evaDidFailWithError:, It is a must! Please implement this one");
    }
    
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
