//
//  EVVoiceLevelMicButtonLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface EVVoiceLevelMicButtonLayer : CAShapeLayer

- (void)audioSessionStarted;
- (void)audioSessionStoped;

- (void)newAudioLevelData:(NSData*)data;

@end
