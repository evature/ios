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

#define BUTTON_DEFAULT_SIZE 60.0f

const NSString* kEVVoiceChatButtonSettigsKey = @"kEVVoiceChatButtonSettigsKey";

@interface EVVoiceChatButton ()

@property (nonatomic, strong) NSMutableDictionary* chatProperties;

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
    self.autoHide = YES;
    self.highlightColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.chatProperties = [NSMutableDictionary dictionary];
    self.micShadowColor = self.backgroundShadowColor = [UIColor blackColor];
    self.micShadowOffset = self.backgroundShadowOffset = CGSizeMake(0.0, -3.0);
    self.micShadowRadius = self.backgroundShadowRadius = 3.0f;
    self.micShadowOpacity = self.backgroundShadowOpacity = 0.0f;
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
    layer.imageLayer.shadowColor = self.micShadowColor.CGColor;
    layer.imageLayer.shadowOffset = self.micShadowOffset;
    layer.imageLayer.shadowOpacity = self.micShadowOpacity;
    layer.imageLayer.shadowRadius = self.micShadowRadius;
    layer.backgroundLayer.shadowColor = self.backgroundShadowColor.CGColor;
    layer.backgroundLayer.shadowOffset = self.backgroundShadowOffset;
    layer.backgroundLayer.shadowOpacity = self.backgroundShadowOpacity;
    layer.backgroundLayer.shadowRadius = self.backgroundShadowRadius;
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
#if !TARGET_INTERFACE_BUILDER
    //We in real app. Init with default frame
    return [self initWithFrame:CGRectMake(0, 0, BUTTON_DEFAULT_SIZE, BUTTON_DEFAULT_SIZE)];
#else
    //We in IB. Simple init and provide default data
    self = [super init];
    if (self != nil) {
        [self setupDefaultData];
    }
    return self;
#endif
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
        [self awakeFromNib];
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
    if ([[self allTargets] count] == 1) {
        if (self.autoHide) {
            [self.chatProperties setObject:[NSValue valueWithNonretainedObject:self] forKey:kEVVoiceChatButtonSettigsKey];
        } else {
            [self.chatProperties removeObjectForKey:kEVVoiceChatButtonSettigsKey];
        }
        [[EVApplication sharedApplication] showChatViewController:((self.connectedController != nil) ? self.connectedController : self) withViewSettings:self.chatProperties];
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
        return [self.chatProperties objectForKey:key];
    }
    return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key hasPrefix:@"chat"]) {
        key = [self controllerPropertyNameFromSelfName:key];
        [self.chatProperties setValue:value forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)controllerWillShow:(UIViewController*)controller {
    self.hidden = NO;
}

- (void)controllerDidHide:(UIViewController*)controller {
    self.hidden = YES;
}

- (void)controllerWillRemove:(UIViewController*)controller {
    [self removeFromSuperview];
}

@end

@implementation EVVoiceChatButton (EVButtonPosition)

- (void)ev_pinToEdge:(NSLayoutAttribute)attribute withOffset:(CGFloat)offset {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.superview
                                                               attribute:attribute
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:attribute
                                                              multiplier:1.0f
                                                                constant:offset]];
}

- (void)ev_addSizeConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:self.frame.size.height]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:self.frame.size.width]];
}

- (void)ev_removeAllConstraints {
    UIView *superview = self.superview;
    while (superview != nil) {
        for (NSLayoutConstraint *c in superview.constraints) {
            if (c.firstItem == self || c.secondItem == self) {
                [superview removeConstraint:c];
            }
        }
        superview = superview.superview;
    }
    
    [self removeConstraints:self.constraints];
}

- (void)ev_pinToBottomCenteredWithOffset:(CGFloat)bottomOffset {
    [self ev_removeAllConstraints];
    [self ev_addSizeConstraints];
    [self ev_pinToEdge:NSLayoutAttributeBottom withOffset:bottomOffset];
    [self ev_pinToEdge:NSLayoutAttributeCenterX withOffset:0.0f];
    
}
- (void)ev_pinToTopCenteredWithOffset:(CGFloat)topOffset {
    [self ev_removeAllConstraints];
    [self ev_addSizeConstraints];
    [self ev_pinToEdge:NSLayoutAttributeTop withOffset:topOffset];
    [self ev_pinToEdge:NSLayoutAttributeCenterX withOffset:0.0f];
}
- (void)ev_pinToBottomLeftCornerWithLeftOffset:(CGFloat)leftOffset andBottomOffset:(CGFloat)bottomOffset {
    [self ev_removeAllConstraints];
    [self ev_addSizeConstraints];
    [self ev_pinToEdge:NSLayoutAttributeBottom withOffset:bottomOffset];
    [self ev_pinToEdge:NSLayoutAttributeLeft withOffset:leftOffset];
    
}
- (void)ev_pinToBottomRightCornerWithRightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset {
    [self ev_removeAllConstraints];
    [self ev_addSizeConstraints];
    [self ev_pinToEdge:NSLayoutAttributeBottom withOffset:bottomOffset];
    [self ev_pinToEdge:NSLayoutAttributeRight withOffset:rightOffset];
}

@end
