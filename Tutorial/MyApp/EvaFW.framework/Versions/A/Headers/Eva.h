//
//  Eva.h
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol EvaDelegate <NSObject>
@optional
- (void)evaDidReceiveData:(NSData *)dataFromServer;  // Called when reciving valid data from Eva.
- (void)evaDidFailWithError:(NSError *)error;
@end

@interface Eva : NSObject<AVAudioRecorderDelegate,CLLocationManagerDelegate>{
    // Optional parameters //
    NSString *uid;
    
    NSString *bias;
    NSString *home;
    NSString *language;
    
    NSString *version; // Optional, @"v1.0" is the default version
    
}

@property (nonatomic, weak) id <EvaDelegate> delegate;

@property(nonatomic,retain) NSString *uid;
@property(nonatomic,retain) NSString *bias;
@property(nonatomic,retain) NSString *home;
@property(nonatomic,retain) NSString *language;

@property(nonatomic,retain) NSString *version;




// Set the API keys //
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code;

// Start record from current active Audio //
- (BOOL)startRecord:(BOOL)withNewSession;

// Stop record, Would send the record to Eva for analyze //
- (BOOL)stopRecord;


@end
