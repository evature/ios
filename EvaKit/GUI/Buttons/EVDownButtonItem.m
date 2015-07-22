//
//  EVDownButtonItem.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVDownButtonItem.h"
#import "EVSVGLayer.h"

@interface EVDownButtonItem ()

- (UIImage*)generateImage;

@end

@implementation EVDownButtonItem

- (UIImage*)generateImage {
    CGRect bounds = [[self performSelector:@selector(view)] bounds];
    EVSVGLayer* layer = [EVSVGLayer layerWithSVGPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"DownArrow" ofType:@"svg"]];
    layer.fillColor = [UIColor blackColor].CGColor;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height+10), NO, [UIScreen mainScreen].scale);
    [layer setFrame:bounds];
    [layer layoutSublayers];
    [layer setNeedsDisplay];
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0f, 10.0f);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.image = [self generateImage];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image = [self generateImage];
}

@end
