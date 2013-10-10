//
//  Eva.m
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "Eva.h"
#import "WaveParser.h"
#import "SpeexEncoder.h"
#import <Speex/Speex.h>

#include "OpenUDID.h"


//#define EVA_API_KEY @"thack-london-june-2012"
//#define EVA_SITE_CODE @"thack"

#define kSamplesPerSecond 16000

#define DEBUG_MODE_FOR_EVA FALSE//TRUE //FALSE

#define SERVER_RESPONSE_TIMEOUT 10.0f//10.0f

#define LEVEL_SAMPLE_TIME 0.03f

#define STOP_RECORD_AFTER_SILENT_TIME_SEC 1.0f

#define MIC_RECORD_TIMEOUT_DEFAULT 8.0f

#define EVA_HOST_ADDRESS @"https://vproxy.evaws.com:443"//@"https://ec2-54-235-35-62.compute-1.amazonaws.com:443"//@"https://vproxy.evaws.com:443"


@interface Eva ()<AVAudioRecorderDelegate,CLLocationManagerDelegate>{
    float latitude,longitude;
    
    BOOL startIsPressed;
    
    NSTimer *levelTimer;
    
    double lowPassResults;
    
    BOOL sendMicLevel;
    
    NSInteger silentMoments;
    
    BOOL startSilenceDetection;
    
    float micRecordTimeout;
    
    //NSString *language;
    
}
//@property(nonatomic) NSInteger amount;

// For audio recording (wav) recording //
@property(retain,nonatomic) AVAudioRecorder *recorder;
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



//@property(nonatomic,retain) IBOutlet UILabel *outputLabel;

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

@synthesize audioTimeoutTimer = audioTimeoutTimer_;

@synthesize version = version_;
@synthesize sendMicLevel = sendMicLevel_;

@synthesize micRecordTimeout = micRecordTimeout_;




+ (Eva *)sharedInstance
{
    static Eva *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[Eva alloc] init];
	}
	return sharedInstance;
}


// External API functions //

/*- (void)initURL:(NSURL *)fileUrl{
    //wavFileUrl_ = fileUrl;
    
}*/

//[Parse setApplicationId:@"M8yI2vyIO6NuTEOCO2e610rT5Z6ipPzREbZe5vBU"
//              clientKey:@"lqW8v0ejSKA5wPYdzGGodd5DbxfXzTVM5CFXZpui"];



- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code{
    evaAPIKey_ = [NSString stringWithFormat:@"%@", api_key];
    evaSiteCode_ = [NSString stringWithFormat:@"%@", site_code];
    
    startIsPressed = FALSE;
    
    sendMicLevel_ = FALSE;
    
    micRecordTimeout_ = MIC_RECORD_TIMEOUT_DEFAULT;
    
    [self initRecordFile]; // New - Less time?
    [self initLocationManager]; // Init the location manager  (takes some time)
    
    return TRUE;
}

- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel{
    [self setAPIkey:api_key withSiteCode:site_code];
    
    sendMicLevel_ = shouldSendMicLevel;  // ********** SHOULD BE ON SOME INIT function ***********
    
    
    return TRUE;
}

- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel withRecordingTimeout:(float)secToTimeout{
    [self setAPIkey:api_key withSiteCode:site_code withMicLevel:shouldSendMicLevel];
    
    micRecordTimeout_ = secToTimeout;
    
    return TRUE;
}

- (BOOL)startRecord:(BOOL)withNewSession{
    NSLog(@"Start recording");
    startSilenceDetection = FALSE;
    if (evaAPIKey_ == nil || evaSiteCode_ == nil) { // Keys are not set
        NSLog(@"Eva: API keys are not set");
        return FALSE; 
    }
    
    if (withNewSession) {
        sessionID_ = [NSString stringWithFormat:@"1"];
    }
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recordToFile];
        
    });*/
    
    [self recordToFile];
    [locationManager_ startUpdatingLocation];
    
    startIsPressed = TRUE;
    
    audioTimeoutTimer_=[NSTimer scheduledTimerWithTimeInterval:micRecordTimeout_//8.0
                                     target:self
                                   selector:@selector(stopRecordOnTick:)
                                   userInfo:nil
                                    repeats:NO];
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: LEVEL_SAMPLE_TIME target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    silentMoments = 0;
    
    return TRUE;
    
}


- (BOOL)stopRecord{
    NSLog(@"Stop recording");
    
    [audioTimeoutTimer_ invalidate];
    audioTimeoutTimer_ = nil;
    if (startIsPressed) {
        [self stopRecordingToFile];
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
        NSLog(@"Eva: Must initiate a startRecord before using stopRecord method");
        return FALSE;
    }
}

-(void)stopRecordOnTick:(NSTimer *)timer {
    [self stopRecord];
}

#pragma mark -
#pragma mark AudioRecordings

-(void)initRecordFile{
    
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
    
   // [recorder_ prepareToRecord];
    //recorder_.meteringEnabled = YES;
    
    [recorder_ prepareToRecord];
    recorder_.meteringEnabled = YES;
    
    
    //[recorder prepareToRecord];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
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

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder_ updateMeters];
    
    const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder_ peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
#if DEBUG_MODE_FOR_EVA
	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder_ averagePowerForChannel:0], [recorder_ peakPowerForChannel:0], lowPassResults);
#endif
    
    if (sendMicLevel_){
        if([[self delegate] respondsToSelector:@selector(evaMicLevelCallbackAverage:andPeak:)]){
            
            [[self delegate] evaMicLevelCallbackAverage:[recorder_ averagePowerForChannel:0] andPeak:[recorder_ peakPowerForChannel:0]];
        }else{
            NSLog(@"Eva-Critical Error: You haven't implemented evaMicLevelCallbackAverage:andPeak, It is a must with your settings. Please implement this one");
        }
        
        
    }
    
    if (lowPassResults > 0.1){
        startSilenceDetection = TRUE;
    }
    if (startSilenceDetection) {
        
    
        if (lowPassResults < 0.05){
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
}

-(void)stopRecordingToFile{
    
    
    [recorder_ stop];
    
    [levelTimer invalidate];
    levelTimer = nil;
    
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
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    if (flag) {
        [self convertFileToSpeex];
    }else{
        NSLog(@"There is a problem with recording");
    }
    
    //[self establishConnection];
    
}

#pragma mark - Speex Handler

-(void)convertFileToSpeex{
    
#if DEBUG_MODE_FOR_EVA
    NSLog(@"convertFileToSpeex");    

    NSLog(@"wavFileUrl_ : %@", wavFileUrl_);//waveFilePath);
   
    NSLog(@"[wavFileUrl_ absoluteString]=%@", [wavFileUrl_ absoluteString]);
#endif
    
    NSError *encodingError;
    SpeexEncoder *spxEncoder = [SpeexEncoder encoderWithMode:speex_wb_mode quality:6
                                            outputSampleRate:SAMPLE_RATE_16000_HZ];
 
#if DEBUG_MODE_FOR_EVA    
    if (spxEncoder == NULL) {
        NSLog(@"spxEncoder == NULL");
    }else{
        NSLog(@"[spxEncoder description]=%@",[spxEncoder description]);
    }
#endif
    
    NSURL *someURL = wavFileUrl_; // some file URL
    NSString *path = [someURL path];
    //NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path];
    
    NSString* expandedPath = [path stringByExpandingTildeInPath];
    //NSURL* audioUrl = [NSURL fileURLWithPath:expandedPath];

#if DEBUG_MODE_FOR_EVA
    NSLog(@"path=%@",path);
    NSLog(@"[url absoluteString]=%@",[wavFileUrl_ absoluteString]);
#endif
    // DEBUG //
    //NSData *_waveData = [NSData dataWithContentsOfFile:path];
    //NSLog(@"[_waveData description]=%@",[_waveData description]);
    ///////////
    
    NSData *spx = [spxEncoder encodeWaveFileAtPath:expandedPath//path//[wavFileUrl_ absoluteString]
                   //waveFilePath
                                             error:&encodingError];
#if DEBUG_MODE_FOR_EVA    
    NSLog(@"Encoding Error: %@", [encodingError description]);
    NSLog(@"ENCODED DATA: %@", spx);
#endif
    
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[documentPath objectAtIndex:0]]; // Get documents directory
    
    NSString *speexOutputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"rec.spx"];
    
    BOOL fileWriteSuccess = [spx writeToFile:speexOutputFile atomically:YES];
    
    // *** ENCODER TESTING ENDS HERE ***
    
    if (fileWriteSuccess) {
        // Send to Eva
        [self establishConnection];
    }else{
        NSLog(@"There was an error saving the file");
    }
}

#pragma mark - Connection with Eva server

-(void)establishConnection{

#if DEBUG_MODE_FOR_EVA
    NSLog(@"***** getUID = %@ *****",[self getUID]); // For test
#endif
    
    NSURL *url;
    
    if (version_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?site_code=%@&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&session_id=%@&uid=%@",EVA_HOST_ADDRESS,version_,evaSiteCode_,evaAPIKey_,ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],sessionID_,[self getUID]]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1.0?site_code=%@&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&session_id=%@&uid=%@",EVA_HOST_ADDRESS,evaSiteCode_,evaAPIKey_,ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],sessionID_,[self getUID]]];
    }
    //url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vproxy.evaws.com:443/?site_code=%@&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&session_id=%@&uid=%@",evaSiteCode_,evaAPIKey_,ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],sessionID_,[self getUID]]];
    
    if (longitude==0 && latitude ==0) { // Check if location services returned a valid value
        
    }else{          // There are GPS coordinates
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&latitude=%.5f&longitude=%.5f",url,latitude,longitude]];
        
        //url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vproxy.evaws.com:443/?site_code=thack&api_key=%@&ip_addr=%@&locale=%@&time_zone=%@&latitude=%.5f&longitude=%.5f",@"thack-london-june-2012",ipAddress_,[self getCurrenLocale],[self getCurrentTimezone],latitude,longitude]];
    }
    
    if (bias_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&bias=%@",url,bias_]];
    }
    if (home_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&home=%@",url,home_]];
    }
    if (language_ != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&language=%@",url,language_]];
    }
#if DEBUG_MODE_FOR_EVA
    NSLog(@"Url = %@",url);
#endif
    
#if TESTFLIGHT_TESTING
    TFLog(@"urlToEva:%@",url);
#endif
    
    
    self.responseData = [[NSMutableData alloc] initWithLength:0] ;
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:SERVER_RESPONSE_TIMEOUT];  // New : Set timeout...
    
    [request setHTTPMethod:@"POST"];
    
    // "Content-Type: audio/x-speex;rate=16000"
    NSString *headerBoundary = [NSString stringWithFormat:@"audio/x-speex;rate=%d",kSamplesPerSecond];
    
    // set header
    [request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
    //Accept-Language: ENUS
    [request addValue:@"ENUS" forHTTPHeaderField:@"Accept-Language"];
    
    // "Accept-Topic: Dictation"
    
    [request addValue:@"Dictation" forHTTPHeaderField:@"Accept-Topic"];
    
    // "Accept: text/plain"
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    //"Transfer-Encoding: chunked"
    ///// Removed to test on iOS 5 //
   
   /* [request addValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"]; */
    
    NSMutableData *postBody = [NSMutableData data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
    NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"rec.spx"]]; 

    
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)[soundData length]]   forHTTPHeaderField:@"content-length"]; // For ios 5 test
    
    [postBody appendData:soundData];
    [postBody appendData:[@"\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
    
    // final boundary
    //[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add body to post
    [request setHTTPBody:postBody];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // You may have received an HTTP 200 here, or not...
    NSLog(@"didReceiveResponse");
    
#if DEBUG_MODE_FOR_EVA
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        //If you need the response, you can use it here
        NSLog(@"httpResponse = %@",[httpResponse description]);
        
        
        int code = [httpResponse statusCode];
        NSLog(@"Response code = %d",code);
       // NSLog(@"httpResponse MIME = %@",[[httpResponse ] lowercaseString]);
    }
#endif
    [responseData_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if([[self delegate] respondsToSelector:@selector(evaDidReceiveData:)]){
        
        [[self delegate] evaDidReceiveData:data];
    }else{
        NSLog(@"Eva-Critical Error: You haven't implemented evaDidReceiveData:, It is a must! Please implement this one");
    }
    
    
    
    
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
    ipAddress_ = [self getIPAddress];
    [self getCurrenLocale];
    
    locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.delegate = self;
    locationManager_.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager_.desiredAccuracy = kCLLocationAccuracyKilometer;//
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Lat&Long: %.5f %.5f", //fabs(
                                       newLocation.coordinate.latitude
          //)
          , //fabs(
          newLocation.coordinate.longitude
          //)
          );
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;
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
    
    NSLog(@"Locale = %@", [currentLocale objectForKey:NSLocaleCountryCode]);
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
            
            
            NSLog(@"%@",externalIP);
            return [NSString stringWithFormat:@"%@",externalIP];
        } else {
            NSLog(@"Oops... g %d, %@",
                  [error code],
                  [error localizedDescription]);
        }
    }
    
    
    
    
    //[pool drain];
    return @"";
}

#pragma mark - MISC for url parameters
-(NSString *)getUID{
    if (uid_!=nil) {  // User set a uid.
        return uid_;
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
