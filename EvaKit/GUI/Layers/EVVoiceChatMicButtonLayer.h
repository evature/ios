//
//  EVVoiceChatMicButtonLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSVGButtonWithCircleBackgroundLayer.h"

@interface EVVoiceChatMicButtonLayer : EVSVGButtonWithCircleBackgroundLayer

@property (nonatomic, assign) CGColorRef highlightColor;
@property (nonatomic, assign) CGFloat spinningBorderWidth;

- (void)hideMic;
- (void)showMic;

- (void)startSpinning;
- (void)stopSpinning;

- (void)audioSessionStarted;
- (void)audioSessionStoped;

- (void)newAudioLevelData:(NSData*)data;
- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume;

@end
