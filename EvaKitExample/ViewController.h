//
//  ViewController.h
//  EvaKitExample
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVChatToolbarContentView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet EVChatToolbarContentView* layerView;

- (IBAction)rotate:(id)sender;

@end

