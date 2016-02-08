//
//  EVApplicationSound.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/21/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVApplicationSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import "EVApplicationSoundDelegate.h"
#import "EVLogger.h"

void endSound (
               SystemSoundID  ssID,
               void           *clientData
               )
{
    EVApplicationSound *_self = (EVApplicationSound*)clientData;
    //EV_LOG_DEBUG(@"Finished playing %@", _self.filePath);
    if (_self.delegate) {
        [_self.delegate didFinishPlay:_self];
    }
}


@interface EVApplicationSound ()

@property (nonatomic, assign, readwrite) SystemSoundID soundId;
@property (nonatomic, strong, readwrite) NSString* filePath;

@end

@implementation EVApplicationSound

+ (instancetype)soundWithPath:(NSString*)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString*)path {
    self = [super init];
    if (self != nil) {
        self.filePath = path;
        NSURL* url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((CFURLRef)url, &_soundId);
        AudioServicesAddSystemSoundCompletion ( _soundId, NULL, NULL, endSound, self );
    }
    return self;
}

- (void)dealloc {
    AudioServicesRemoveSystemSoundCompletion(self.soundId);
    AudioServicesDisposeSystemSoundID(self.soundId);
    [super dealloc];
}

- (void)play {
    EV_LOG_DEBUG(@"Playing %@", self.filePath);
    AudioServicesPlaySystemSound(self.soundId);
}

@end
