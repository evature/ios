//
//  EVSVGLayer.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSVGLayer.h"
#import "PocketSVG.h"

@implementation EVSVGLayer

+ (instancetype)layerWithSVGPath:(NSString*)svgPath {
    return [[[self alloc] initWithSVGPath:svgPath] autorelease];
}

- (instancetype)initWithSVGPath:(NSString*)svgPath {
    self = [super init];
    if (self != nil) {
        [self showSVGFileAtPath:svgPath];
    }
    return self;
}

- (void)showSVGFileAtPath:(NSString*)svgPath {
    self.path = [PocketSVG pathFromSVGFileAtURL:[NSURL fileURLWithPath:svgPath]];
}

@end
