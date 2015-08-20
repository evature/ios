//
//  EVApplicationSound.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/21/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVApplicationSound.h"
#import <AudioToolbox/AudioToolbox.h>

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
        NSURL* url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((CFURLRef)url, &_soundId);
    }
    return self;
}

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(self.soundId);
    [super dealloc];
}

- (void)play {
    AudioServicesPlaySystemSound(self.soundId);
}

@end
