//
//  SpeexEncoder.h
//  SpeexKit
//
//  Created by Ryan Wang on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <speex/speex.h>

#define FRAME_SIZE 160

@interface SpeexEncoder : NSObject

+ (NSString *)version;
+ (NSString *)longVersion;


@end
