//
//  MOAudioStreamer.h
//   
//
//  Created by moath othman on 5/22/13.
//  Under MIT License
//  dark2torch@gmail.com

#import <UIKit/UIKit.h>
#import "Recorder.h"

@class MOAudioStreamer;

@protocol MOAudioStreamerDelegate <NSObject>

-(void)MOAudioStreamerDidFinishStreaming:(MOAudioStreamer*)streamer;
-(void)MOAudioStreamerDidFinishRequest:(MOAudioStreamer*)streamer theConnection:(NSURLConnection*)connectionRequest withResponse:(NSString*)response;
-(void)MOAudioStreamerDidFailed:(MOAudioStreamer*)streamer message:(NSString*)reason;

- (void)MOAudioStreamerConnection:(MOAudioStreamer*)streamer theConnection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)MOAudioStreamerConnection:(MOAudioStreamer*)streamer theConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)MOAudioStreamerConnection:(MOAudioStreamer*)streamer theConnection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error;
- (void)MOAudioStreamerConnectionDidFinishLoading:(MOAudioStreamer*)streamer theConnection:(NSURLConnection *)theConnection;

- (void)MORecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;

@end
 
@interface MOAudioStreamer : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate
,RecorderDelegate
>
{
    NSString*soundFilePath;
    NSString*soundOFilePath;
 @public   BOOL StopSignal;
     
//    NSMutableData *responseData;
    dispatch_queue_t _streamDispatch;

    BOOL giveMeResults;
    
    
    BOOL orderToStop;
    @public  NSError *connectionError;
//    BOOL stopSendingStupidData;

    NSMutableURLRequest *   request;
    
    BOOL sleptAlready;

}


@property(strong,nonatomic) NSMutableURLRequest *   request;;
@property(assign,nonatomic)NSTimeInterval expectingTimeOut;
@property(assign)id<MOAudioStreamerDelegate>streamerDelegate;
@property(strong,nonatomic)NSString*recordingPath;
@property(strong,nonatomic)NSString *webServiceURL;
@property(strong,nonatomic)NSString *fileToSaveName;
@property(retain,nonatomic)NSString*password;
@property(retain,nonatomic)NSString*userName;
@property (nonatomic, strong) Recorder *recorder;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
//@property(assign)int lol;

+ (MOAudioStreamer *)sharedInstance;
 - (void)startStreamer;
-(void)stopStreaming;
- (void)cancelStreaming;

-(float)averagePower;
-(float)peakPower;

//- (void)recorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;
@end
