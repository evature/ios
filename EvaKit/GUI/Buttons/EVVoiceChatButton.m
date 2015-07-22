//
//  EVVoiceChatButton.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatButton.h"
#import "PocketSVG.h"
#import "EVApplication.h"
#import "EVVoiceChatMicButtonLayer.h"

@interface EVVoiceChatButton ()

@property (nonatomic, strong) NSMutableDictionary* toolbarProperties;

- (UIImage *)generateImage;
- (UIImage *)generateHighlightMask;
- (NSString*)controllerPropertyNameFromSelfName:(NSString*)name;

- (IBAction)clicked:(id)button;

@end

@implementation EVVoiceChatButton

@dynamic chatToolbarCenterButtonMicLineColor;
@dynamic chatToolbarCenterButtonMicLineWidth;
@dynamic chatToolbarCenterButtonMicColor;
@dynamic chatToolbarCenterButtonMicScale;
@dynamic chatToolbarCenterButtonBackgroundColor;
@dynamic chatToolbarCenterButtonBorderColor;
@dynamic chatToolbarCenterButtonHighlightColor;
@dynamic chatToolbarCenterButtonBorderWidth;
@dynamic chatToolbarCenterButtonSpinningBorderWidth;

@dynamic chatToolbarLeftRightButtonsBackgroundColor;
@dynamic chatToolbarLeftRightButtonsImageColor;
@dynamic chatToolbarLeftRightButtonsBorderColor;
@dynamic chatToolbarLeftRightButtonsBorderWidth;
@dynamic chatToolbarLeftRightButtonsImageScale;
@dynamic chatToolbarLeftRightButtonsUnactiveBackgroundScale;
@dynamic chatToolbarLeftRightButtonsActiveBackgroundScale;
@dynamic chatToolbarLeftRightButtonsMaxImageScale;
@dynamic chatToolbarLeftRightButtonsMaxBackgroundScale;

@dynamic chatToolbarLeftRightButtonsOffset;

- (void)setupDefaultData {
    self.micLineWidth = 0.0f;
    self.micLineColor = self.micFillColor = [UIColor whiteColor];
    self.borderLineWidth = 1.0f;
    self.borderLineColor = [UIColor whiteColor];
    self.backgroundFillColor = [UIColor colorWithRed:208.0f/255.0f green:67.0f/255.0f blue:62.0f/255.0f alpha:0.9f];
    self.micScaleFactor = 0.75f;
    self.highlightColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.toolbarProperties = [NSMutableDictionary dictionary];
}

- (UIImage*)generateImage {
    EVVoiceChatMicButtonLayer* layer = [EVVoiceChatMicButtonLayer layer];
    layer.svgLineWidth = self.micLineWidth;
    layer.svgLineColor = self.micLineColor.CGColor;
    layer.svgFillColor = self.micFillColor.CGColor;
    layer.svgScaleFactor = self.micScaleFactor;
    layer.borderLineWidth = self.borderLineWidth;
    layer.backgroundFillColor = self.backgroundFillColor.CGColor;
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
    self.backgroundColor = [UIColor clearColor];
    [self setBackgroundImage:[self generateImage] forState:UIControlStateNormal];
}

- (IBAction)clicked:(id)button {
    if ([[self actionsForTarget:nil forControlEvent:UIControlEventTouchUpInside] count] == 0) {
        [[EVApplication sharedApplication] showChatViewController:self withViewSettings:self.toolbarProperties];
    }
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    [self addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.imageView.image == nil) {
        [self setBackgroundImage:[self generateImage] forState:UIControlStateNormal];
        [self setImage:[self generateHighlightMask] forState:UIControlStateHighlighted];
    }
}

- (NSString*)controllerPropertyNameFromSelfName:(NSString*)name {
    //name = [name substringFromIndex:4]; //Removes "chat" from name
    //Searching for first big button after size("chat")+1 button. This is for position of real property name
    NSUInteger pos = [name rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet] options:0 range:NSMakeRange(5, [name length]-5)].location;
    //Get object name
    NSString *obj = [[name substringWithRange:NSMakeRange(4, pos-4)] lowercaseString];
    //Get property name and make first letter lowercase
    name = [[[name substringWithRange:NSMakeRange(pos, 1)] lowercaseString] stringByAppendingString:[name substringWithRange:NSMakeRange(pos+1, [name length]-pos-1)]];
    //combine path
    return [obj stringByAppendingPathExtension:name];
}

- (id)valueForUndefinedKey:(NSString *)key {
    if ([key hasPrefix:@"chat"]) {
        key = [self controllerPropertyNameFromSelfName:key];
        return [self.toolbarProperties objectForKey:key];
    }
    return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key hasPrefix:@"chat"]) {
        key = [self controllerPropertyNameFromSelfName:key];
        [self.toolbarProperties setValue:value forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

@end
