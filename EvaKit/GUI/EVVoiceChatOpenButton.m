//
//  EVVoiceChatOpenButton.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatOpenButton.h"
#import "PocketSVG.h"
#import "EVApplication.h"
#import "EVVoiceChatMicButtonLayer.h"

@interface EVVoiceChatOpenButton ()

- (UIImage *)generateImage;
- (UIImage *)generateHighlightMask;


- (IBAction)clicked:(id)button;


@end

@implementation EVVoiceChatOpenButton

- (void)setupDefaultData {
    self.micLineWidth = 0.0f;
    self.micLineColor = self.micFillColor = [UIColor whiteColor];
    self.borderLineWidth = 1.0f;
    self.borderLineColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor redColor];
    self.micScaleFactor = 0.9;
}

- (UIImage*)generateImage {
    EVVoiceChatMicButtonLayer* layer = [EVVoiceChatMicButtonLayer layer];
    layer.micLineWidth = self.micLineWidth;
    layer.micLineColor = self.micLineColor.CGColor;
    layer.micFillColor = self.micFillColor.CGColor;
    layer.micScaleFactor = self.micScaleFactor;
    layer.borderLineWidth = self.borderLineWidth;
    layer.backgroundFillColor = self.backgroundColor.CGColor;
    layer.borderLineColor = self.borderLineColor.CGColor;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [layer setFrame:self.bounds];
    [layer layoutSublayers];
    [layer setNeedsDisplay];
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)generateHighlightMask {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.highlightColor setFill];
    CGSize size = self.bounds.size;
    CGFloat raduis = (MIN(size.width, size.height) / 2.0f);
    
    CGContextAddArc(ctx, size.width / 2.0f, size.height / 2.0f, raduis, 0.0, 2*M_PI, 0);
    CGContextDrawPath(ctx, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setupDefaultData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupDefaultData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setupDefaultData];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)prepareForInterfaceBuilder {
    [self setBackgroundImage:[self generateImage] forState:UIControlStateNormal];
}

- (IBAction)clicked:(id)button {
    if ([[self actionsForTarget:nil forControlEvent:UIControlEventTouchUpInside] count] == 0) {
        [[EVApplication sharedApplication] showChatViewController:self];
    }
}

- (void)awakeFromNib {
    [self addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.imageView.image == nil) {
        [self setBackgroundImage:[self generateImage] forState:UIControlStateNormal];
        [self setImage:[self generateHighlightMask] forState:UIControlStateHighlighted];
    }
}

@end
