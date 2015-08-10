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
        self.logHandler = ^(NSString* message) {
            NSLog(@"%@", message);
        };
        self.errorLogHandler = NULL;
        self.debugLogHandler = NULL;
        self.infoLogHandler = NULL;
    }
    return self;
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
        self.debugLogHandler(debugString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelDebug) {
            self.logHandler([NSString stringWithFormat:@"DEBUG: %@", debugString]);
        }
    }
}
- (void)logInfoString:(NSString*)infoString {
    if (self.infoLogHandler != NULL) {
        self.infoLogHandler(infoString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelInfo) {
            self.logHandler([NSString stringWithFormat:@"INFO: %@", infoString]);
        }
    }
}

- (void)logErrorString:(NSString*)errorString {
    if (self.errorLogHandler != NULL) {
        self.errorLogHandler(errorString);
    } else {
        if (self.logLevel >= EVLoggerLogLevelError) {
            self.logHandler([NSString stringWithFormat:@"ERROR: %@", errorString]);
        }
    }
}

@end
