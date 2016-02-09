//
//  EVCallbackResult.m
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "EVCallbackResult.h"


@interface EVCallbackResultData : NSObject

@property (nonatomic, assign, readwrite) BOOL appendToEvaSayIt;  // append the display/say strings to the Eva reply
@property (nonatomic, assign, readwrite) BOOL closeChat;  // set to true to close the chat screen immediately after the result handling is complete
@property (nonatomic, assign, readwrite) BOOL startRecordAfterSpeak; // set to true to automatically start recording as soon as the speak is finished

@property (nonatomic, strong, readwrite) NSString* sayIt;
@property (nonatomic, strong, readwrite) EVStyledString* displayIt;
@property (nonatomic, strong, readwrite) RXPromise* deferredResult;


@end

@interface EVCallbackResult () {
    //NSInteger resultsCount;
}


@property (nonatomic, copy) EVCallbackResultData* data;

- (instancetype)initWithDisplay:(EVStyledString *)displayString andSayString:(NSString*)sayString andPromise:(RXPromise*)promise;

//@property (nonatomic, assign) NSInteger resultsCount;


@end


@implementation EVCallbackResult


// default handling - say+display Eva's text  - same as returning nil
+ (instancetype)resultDefault {
    return [[[self alloc] initWithDisplay:nil andSayString:nil andPromise:nil] autorelease];
}
+ (instancetype) resultWithNone {
    return [EVCallbackResult resultDefault];
}

// do nothing (no say nor display)
+ (instancetype)resultDoNothing {
    return [[[self alloc] initWithDisplay:[EVStyledString styledStringWithString:@""] andSayString:@"" andPromise:nil] autorelease];
}

// display+say the same string
+ (instancetype)resultWithStyledString:(EVStyledString*)stringValue {
    return [[[self alloc] initWithDisplay:stringValue andSayString:[stringValue string] andPromise:nil] autorelease];
}
+ (instancetype)resultWithString:(NSString*)stringValue {
    return [[[self alloc] initWithDisplay:[EVStyledString styledStringWithString:stringValue] andSayString:stringValue andPromise:nil] autorelease];
}


// display one string and say another
+ (instancetype)resultWithDisplayString:(EVStyledString*)displayValue andSayString:(NSString*)sayString {
    return [[[self alloc] initWithDisplay:displayValue andSayString:sayString andPromise:nil] autorelease];
}

// the promise will resolve to a EVCallbackResult, nothing will be spoken/displayed until then
+ (instancetype)resultWithPromise:(RXPromise*)promise {
    return [[[self alloc] initWithDisplay:[EVStyledString styledStringWithString:@""] andSayString:@"" andPromise:promise] autorelease];
}

// handle the immediate result (eg. say/display) and then replace it with the result which will be resolved by the promise
+ (instancetype)resultWithPromise:(RXPromise*)promise andImmediateResult:(EVCallbackResult*)immediate {
    EVCallbackResult *result = [[[self alloc] initWithDisplay:immediate.data.displayIt andSayString:immediate.data.sayIt andPromise:promise] autorelease];
    result.data.closeChat = immediate.data.closeChat;
    result.data.appendToEvaSayIt = immediate.data.appendToEvaSayIt;
    return result;
}

- (EVStyledString*)displayIt {
    return [_data displayIt];
}
- (NSString*)sayIt {
    return [_data sayIt];
}
- (RXPromise*)deferredResult {
    return [_data deferredResult];
}
- (BOOL)closeChat {
    return [_data closeChat];
}
- (BOOL)appendToEvaSayIt {
    return [_data appendToEvaSayIt];
}
- (BOOL)startRecordAfterSpeak {
    return [_data startRecordAfterSpeak];
}


- (void) setDisplayIt:(EVStyledString*)displayIt {
    if (_data != nil)
        _data.displayIt = displayIt;
}
- (void)setSayIt:(NSString*)sayIt {
    if (_data != nil)
        _data.sayIt = sayIt;
}
- (void)setDeferredResult:(RXPromise*)deferredResult {
    if (_data != nil)
        _data.deferredResult = deferredResult;
}
- (void)setCloseChat:(BOOL)closeChat {
    if (_data != nil)
        _data.closeChat = closeChat;
}
- (void)setAppendToEvaSayIt:(BOOL)appendToEvaSayIt {
    if (_data != nil)
        _data.appendToEvaSayIt = appendToEvaSayIt;
}
-(void)setStartRecordAfterSpeak:(BOOL)startRecord {
    if (_data != nil)
        _data.startRecordAfterSpeak = startRecord;
}


- (instancetype)initWithDisplay:(EVStyledString *)displayString andSayString:(NSString*)sayString andPromise:(RXPromise*)promise {
    self = [super init];
    if (self != nil) {
        _data = [[EVCallbackResultData alloc] init];
        _data.sayIt = sayString;
        _data.displayIt = displayString;
        _data.deferredResult = promise;
    }
    return self;
}

- (void)dealloc {
    _data = nil;
    [super dealloc];
}

@end


@implementation EVCallbackResultData


-(id)copyWithZone:(NSZone*)zone {
    EVCallbackResultData *copy = [[[self class] allocWithZone: zone] init];
    copy.sayIt = [self.sayIt copy];
    copy.displayIt = [self.displayIt copy];
    copy.deferredResult = self.deferredResult;
    copy.appendToEvaSayIt = self.appendToEvaSayIt;
    copy.closeChat = self.closeChat;
    return copy;
}


- (void)dealloc {
        self.sayIt = nil;
        self.displayIt = nil;
        [super dealloc];
    }

@end


