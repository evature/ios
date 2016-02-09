//
//  EVCallbackResult.h
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RXPromise/RXPromise.h>
#import "EVStyledString.h"




@interface EVCallbackResult : NSObject



// default handling - say+display Eva's text  - same as returning nil from the callback
+ (instancetype)resultDefault;
+ (instancetype)resultWithNone;

// do nothing (no say nor display)
+ (instancetype)resultDoNothing;

// display+say the same string
+ (instancetype)resultWithStyledString:(EVStyledString*)stringValue;
+ (instancetype)resultWithString:(NSString*)stringValue;

// display one string and say another
+ (instancetype)resultWithDisplayString:(EVStyledString*)displayValue andSayString:(NSString*)sayString;  // nil = default Eva,  @"" = do not display/speak

// the promise will resolve to a EVCallbackResult, nothing will be spoken/displayed until then
+ (instancetype)resultWithPromise:(RXPromise*)promise;

// handle the immediate result (eg. say/display) and then replace it with the result which will be resolved by the promise
+ (instancetype)resultWithPromise:(RXPromise*)promise andImmediateResult:(EVCallbackResult*)immediate;


@property (nonatomic, assign, readwrite) BOOL appendToEvaSayIt;  // append the display/say strings to the Eva reply
@property (nonatomic, assign, readwrite) BOOL closeChat;  // set to true to close the chat screen immediately after the result handling is complete
@property (nonatomic, assign, readwrite) BOOL startRecordAfterSpeak;
@property (nonatomic, strong, readwrite) NSString* sayIt;
@property (nonatomic, strong, readwrite) EVStyledString* displayIt;
@property (nonatomic, strong, readwrite) RXPromise* deferredResult;




@end
