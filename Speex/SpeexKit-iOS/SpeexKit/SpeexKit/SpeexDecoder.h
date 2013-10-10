//
//  SpeexDecoder.h
//  SpeexKit
//
//  Created by Ryan Wang on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <speex/speex.h>
#import <ogg/ogg.h>
#include <speex/speex_header.h>
#include <speex/speex_stereo.h>
#include <speex/speex_callbacks.h>

#define FRAME_SIZE 160


@interface SpeexDecoder : NSObject <NSStreamDelegate>{
    __weak id       _delegate;
    NSInputStream   *_inputStream;
    NSOutputStream  *_outputStream;
}

+ (NSString *)version;
+ (NSString *)longVersion;

- (id)initWithEncodedFile:(NSString *)filePath delegate:(id)aDelegate;

- (void)start NS_AVAILABLE(10_5, 2_0);
- (void)cancel;

@end


@protocol SpeexDecodeDelegate <NSObject>

@optional

- (void)decoder:(SpeexDecoder *)decoder didDecodedData:(NSData *)data;
- (void)decodeFinished:(SpeexDecoder *)decoder;

@end
