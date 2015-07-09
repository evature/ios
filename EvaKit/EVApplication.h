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

+ (instancetype)sharedApplication;


// Sender can be View Controller or View
- (void)showChatViewController:(id)sender;

@end
