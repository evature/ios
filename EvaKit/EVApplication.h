//
//  EVApplication.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVApplication : NSObject

@property (nonatomic, assign, readwrite) Class chatViewControllerClass;


// Dictionary with Chat View settings path rewrites. For more simple configuration and Chat Button.
@property (nonatomic, strong, readonly) NSMutableDictionary* chatViewControllerPathRewrites;

+ (instancetype)sharedApplication;


// Sender can be View Controller or View
- (void)showChatViewController:(id)sender withViewSettings:(NSDictionary*)viewSettings;

@end
