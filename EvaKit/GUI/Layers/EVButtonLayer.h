//
//  EVButtonLayer.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface EVButtonLayer : CALayer {
    CALayer* _highlightLayer;
    CALayer* _imageLayer;
    CALayer* _backgroundLayer;
}

@property (nonatomic, strong) CALayer* highlightLayer;
@property (nonatomic, strong) CALayer* imageLayer;
@property (nonatomic, strong) CALayer* backgroundLayer;

- (void)touched;
- (void)released;

@end
