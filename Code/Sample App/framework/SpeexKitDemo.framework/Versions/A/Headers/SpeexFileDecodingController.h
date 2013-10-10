//
//  SpeexFileDecodingController.h
//  SpeexKit
//
//  Created by Halle Winkler on 2/18/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class  SpeexFileDecodingController
 @brief  A class that decodes complete speex audio files into complete WAV or raw audio files.
 */

@interface SpeexFileDecodingController : NSObject {

    BOOL verboseSpeexFileDecodingController;    
}

/** This takes one entire spx file and converts it to a wav or raw file with a header.*/
- (void) decodeLocalSpeexFileAtPath:(NSString *)localSpeexFile intoLocalRawOrWavFileAtPath:(NSString *)decodedFile; 
/** Set this TRUE in order to see error output */
@property(nonatomic,assign) BOOL verboseSpeexFileDecodingController;   

@end
