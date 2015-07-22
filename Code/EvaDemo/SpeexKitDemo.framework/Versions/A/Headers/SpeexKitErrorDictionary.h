//
//  SpeexKitErrorDictionary.h
//  SpeexKit
//
//  Created by Halle Winkler on 2/27/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//


#define kSpeexKitErrorDomain @"SpeexKitErrorDomain"

#define kSpeexKitErrorUnableToWriteOutWavFileCode 100
#define kSpeexKitErrorUnableToWriteOutWavFileMessage @"Unable to write out WAV File"
#define kSpeexKitErrorUnableToWriteOutWavFile [NSError errorWithDomain:kSpeexKitErrorDomain code:kSpeexKitErrorUnableToWriteOutWavFileCode userInfo:[NSDictionary dictionaryWithObject:kSpeexKitErrorUnableToWriteOutWavFileMessage forKey:NSLocalizedDescriptionKey]];
