//
//  EVVoiceLevelMicButtonLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(char, EVGraphAlignment) {
    EVGraphAlignmentLeft,
    EVGraphAlignmentRight,
    EVGraphAlignmentCenter
};

@interface EVVoiceLevelMicButtonLayer : CAShapeLayer

@property (nonatomic, assign) BOOL isFishEyeEnabled;
@property (nonatomic, assign) EVGraphAlignment graphAlignment;
@property (nonatomic, assign) BOOL extendLine;

- (void)audioSessionStarted;
- (void)audioSessionStoped;

- (void)newAudioLevelData:(NSData*)data;
- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume;

@end
