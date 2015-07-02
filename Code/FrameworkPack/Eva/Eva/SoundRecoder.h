//
//  AudioRecoder.h
//  SpeechRecognizer
//
//  Created by hayashi on 1/31/13.
//  Copyright (c) 2013 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SoundRecoder;

@protocol SoundRecoderDelegate <NSObject>
-(void)soundRecoderDidFinishRecording:(SoundRecoder*)recoder;
@end

@interface SoundRecoder : NSObject
@property (nonatomic,retain) id<SoundRecoderDelegate> delegate;
@property (nonatomic,readonly) NSString *savedPath;
-(BOOL)startRecording:(NSString*)savePath;
-(BOOL)stopRecording;
@end
