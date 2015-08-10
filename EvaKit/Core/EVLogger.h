//
//  EVLogger.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/10/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EV_LOG_BUILD_LOG_STRING(__fmt, ...) [NSString stringWithFormat:(@"%s(Line: %d) "__fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

#define EV_LOG_ERROR_OBJ(__error) [[EVLogger logger] logError:__error]

#define EV_LOG_ERROR(__fmt, ...) [[EVLogger logger] logErrorString:EV_LOG_BUILD_LOG_STRING(__fmt, ##__VA_ARGS__)]
#define EV_LOG_INFO(__fmt, ...) [[EVLogger logger] logInfoString:EV_LOG_BUILD_LOG_STRING(__fmt, ##__VA_ARGS__)]
#define EV_LOG_DEBUG(__fmt, ...) [[EVLogger logger] logDebugString:EV_LOG_BUILD_LOG_STRING(__fmt, ##__VA_ARGS__)]

typedef void(^EVLoggerLogHandler)(NSString* message);
typedef NS_ENUM(char, EVLoggerLogLevel) {
    EVLoggerLogLevelError = 0,
    EVLoggerLogLevelInfo,
    EVLoggerLogLevelDebug
};

@interface EVLogger : NSObject

@property (nonatomic, assign, readwrite) EVLoggerLogLevel logLevel;

// This is common handler. It uses log level setting. By default printing to console.
@property (nonatomic, copy, readwrite) EVLoggerLogHandler logHandler;

// This is typed handlers. They ignores log level setting. By default they NULL.
// If provided then common log handler will be not called
@property (nonatomic, copy, readwrite) EVLoggerLogHandler debugLogHandler;
@property (nonatomic, copy, readwrite) EVLoggerLogHandler infoLogHandler;
@property (nonatomic, copy, readwrite) EVLoggerLogHandler errorLogHandler;

+ (instancetype)logger;

- (void)logError:(NSError*)error;
- (void)logDebugString:(NSString*)debugString;
- (void)logInfoString:(NSString*)infoString;
- (void)logErrorString:(NSString*)errorString;

@end
