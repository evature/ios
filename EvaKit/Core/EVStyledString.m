//
//  EVStyledString.m
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "EVStyledString.h"

@interface EVStyledString ()

@property (nonatomic, strong) id value;
@property (nonatomic, assign, readwrite) BOOL hasStyle;

- (instancetype)initWithValue:(id)value hasStyle:(BOOL)hasStyle;

@end

@implementation EVStyledString

+ (instancetype)styledStringWithString:(NSString*)aString {
    return [[[self alloc] initWithString:aString] autorelease];
}

+ (instancetype)styledStringWithAttributedString:(NSAttributedString*)aString {
    return [[[self alloc] initWithAttributedString:aString] autorelease];
}

- (instancetype)initWithString:(NSString*)aString {
    return [self initWithValue:aString hasStyle:NO];
}

- (instancetype)initWithAttributedString:(NSAttributedString*)aString {
    return [self initWithValue:aString hasStyle:YES];
}

- (instancetype)initWithValue:(id)value hasStyle:(BOOL)hasStyle {
    self = [super init];
    if (self != nil) {
        self.value = value;
        self.hasStyle = hasStyle;
    }
    return self;
}

- (void)dealloc {
    self.value = nil;
    [super dealloc];
}

- (NSString*)string {
    if (self.hasStyle) {
        return [(NSAttributedString*)self.value string];
    }
    return self.value;
}

- (NSAttributedString*)attributedString {
    if (!self.hasStyle) {
        return [[[NSAttributedString alloc] initWithString:self.value] autorelease];
    }
    return self.value;
}

-(id)copyWithZone:(NSZone*)zone {
    EVStyledString *copy = [[[self class] allocWithZone: zone] init];
    copy.value = self.value;
    copy.hasStyle = self.hasStyle;
    return copy;
}

@end
