//
//  EVLogger.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/10/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVLogger.h"

@implementation EVLogger

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.logLevel = EVLoggerLogLevelError;
        self.logHandler = ^(EVLoggerLogLevel level, NSString* message) {
            switch (level) {
                case EVLoggerLogLevelDebug:
                    NSLog(@"DEBUG: %@", message);
                    break;
                case EVLoggerLogLevelError:
                    NSLog(@"ERROR: %@", message);
                    break;
                default:
                    NSLog(@"INFO: %@", message);
                    break;
            }
        };
        self.errorLogHandler = NULL;
        self.debugLogHandler = NULL;
        self.infoLogHandler = NULL;
    }
    return self;
}

- (void)dealloc {
    self.logHandler = NULL;
    self.errorLogHandler = NULL;
    self.debugLogHandler = NULL;
    self.infoLogHandler = NULL;
    [super dealloc];
}

+ (instancetype)logger {
    static EVLogger* sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[EVLogger alloc] init];
    });
    return sharedInstance;
}

- (void)logError:(NSError*)error {
    [self logErrorString:[error description]];
}

- (void)logDebugString:(NSString*)debugString {
    if (self.debugLogHandler != NULL) {
        self.debugLogHandler(EVLoggerLogLevelDebug, debugString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelDebug) {
            self.logHandler(EVLoggerLogLevelDebug, debugString);
        }
    }
}
- (void)logInfoString:(NSString*)infoString {
    if (self.infoLogHandler != NULL) {
        self.infoLogHandler(EVLoggerLogLevelInfo, infoString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelInfo) {
            self.logHandler(EVLoggerLogLevelInfo, infoString);
        }
    }
}

- (void)logErrorString:(NSString*)errorString {
    if (self.errorLogHandler != NULL) {
        self.errorLogHandler(EVLoggerLogLevelError, errorString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelError) {
            self.logHandler(EVLoggerLogLevelError, errorString);
        }
    }
}

@end
