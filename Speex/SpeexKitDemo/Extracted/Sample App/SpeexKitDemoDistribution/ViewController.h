//
//  ViewController.h
//  SpeexKitDemo
//
//  Created by Halle Winkler on 2/17/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <SpeexKitDemo/SpeexNSDataEncodingController.h>
#import <SpeexKitDemo/SpeexNSDataDecodingController.h>

#import <UIKit/UIKit.h>
#import "ContinuousAudioUnit.h"
#import "AudioSessionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UIBubbleTableViewDataSource.h"
#import <QuartzCore/QuartzCore.h>

#import "Common.h"
#import "DataViewController.h"

// TTS library //
#import <Slt/Slt.h>
#import <Awb/Awb.h>
#import <Kal/Kal.h>
#import <OpenEars/FliteController.h>


@interface ViewController : UIViewController <ContinuousAudioUnitDelegate, SpeexNSDataEncodingControllerDelegate, SpeexNSDataDecodingControllerDelegate,CLLocationManagerDelegate,UIBubbleTableViewDataSource,DataViewControllerDelegate> {
    AudioSessionManager *audioSessionManager;
    int buffersConverted;
    int buffersDecoded;    
    NSMutableArray *bufferArray;
    NSMutableArray *rawSamplesArray;
    SpeexNSDataEncodingController *speexNSDataEncodingController;
    SpeexNSDataDecodingController *speexNSDataDecodingController;
    NSMutableData *completeBuffer;
    ContinuousAudioUnit *continuousAudioUnit;
    int numberOfCallbacksToRecordFor;
    int speexFramesCreated;
    int decodedBuffers;
    
    BOOL askForStopRecording; // Would be TRUE when user want to stop live recording
    
    NSMutableData * responseData;
    NSURLConnection * connection;
    
    NSString *ipAddress;
    
    CLLocationManager *locationManager;
    
    float latitude,longitude;
    
    IBOutlet UILabel *outputLabel;
    
    IBOutlet UIBubbleTableView *bubbleTable;
    
    NSMutableArray *bubbleData;
    
    CAEmitterLayer *emitterLayer;
    
    CFURLRef		tickSoundFileURLRef;
	SystemSoundID	tickSoundFileObject;
    
    //IBOutlet UIButton *dataButton;
    
    // OpenEars //
    FliteController *fliteController;
    Slt *slt;
 //   Awb *awb;
 //   Kal *kal;
    /////////////

    
}

@property(nonatomic,assign) int buffersConverted;
@property(nonatomic,assign) int buffersDecoded; 
@property(nonatomic,retain) NSMutableArray *bufferArray;
@property(nonatomic,retain) AudioSessionManager *audioSessionManager;
@property(nonatomic,retain) NSMutableArray *rawSamplesArray;
@property(nonatomic,retain) SpeexNSDataEncodingController *speexNSDataEncodingController;
@property(nonatomic,retain) SpeexNSDataDecodingController *speexNSDataDecodingController;
@property(nonatomic,retain) NSMutableData *completeBuffer;
@property(nonatomic,retain) ContinuousAudioUnit *continuousAudioUnit;
@property(nonatomic,assign) int numberOfCallbacksToRecordFor;

@property(nonatomic,assign) int speexFramesCreated;
@property(nonatomic,assign) int decodedBuffers;

@property(nonatomic,retain) NSMutableData * responseData;
@property(nonatomic,retain) NSURLConnection * connection;
@property(nonatomic,retain) NSString *ipAddress;
@property(nonatomic,retain) IBOutlet UILabel *outputLabel;

@property(nonatomic,retain) IBOutlet UIBubbleTableView *bubbleTable;
@property(nonatomic,retain) NSMutableArray *bubbleData;

@property (retain , nonatomic) CAEmitterLayer *emitterLayer;
//@property (retain , nonatomic) ViewStateType curViewState;

@property (readwrite)	CFURLRef		tickSoundFileURLRef;
@property (readonly)	SystemSoundID	tickSoundFileObject;

// OpenEars //
@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
//@property (strong, nonatomic) Awb *awb;
//@property (strong, nonatomic) Kal *kal;


-(IBAction)startRecording:(id)sender;
-(IBAction)stopRecording:(id)sender;

- (IBAction)dataButtonPressed:(id)sender;

@end
