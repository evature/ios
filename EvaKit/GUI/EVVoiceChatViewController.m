//
//  EVVoiceChatViewController.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatViewController.h"
#import "EVChatToolbarcontentView.h"
#import "UIImageEffects.h"
#import "EVCollectionViewFlowLayout.h"
#import <objc/runtime.h>
#import "EVApplication.h"

#define RGBA_COLOR(_red, _green, _blue, _alpha) [UIColor colorWithRed:_red/255.0f green:_green/255.0f blue:_blue/255.0f alpha:_alpha/255.0f]
#define RGBA_HEX_COLOR(_red, _green, _blue, _alpha) RGBA_COLOR(0x##_red, 0x##_green, 0x##_blue, 0x##_alpha)

#define UI_BAR_HEIGHT_PORTRAIT 40
#define UI_BAR_HEIGHT_LANDSCAPE 32

id emptyInitMethod(id lookupObject, SEL selector) {
    [lookupObject init];
    [lookupObject release];
    return nil;
}

NSString* const kSenderIdMe = @"me";
NSString* const kSenderDisplayNameMe = @"Me";
NSString* const kSenderIdEva = @"eva";
NSString* const kSenderDisplayNameEva = @"Eva";

@interface EVVoiceChatViewController ()

@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSDictionary* viewSettings;

- (UIImage*)imageOfBackgroundView;

- (void)recordTimerFired:(NSTimer*)timer;
- (void)myMessageSend;
- (void)getResponseMessage;

@end

@implementation EVVoiceChatViewController

@dynamic collectionView;
@dynamic inputToolbar;
@dynamic toolbarHeightConstraint;
@dynamic toolbarBottomLayoutGuide;


+ (void)initialize {
    // This is workaround for creating of keyboard controller (which can't work without text view in toolbar). Replacing init with empty init
    SEL allocSel = @selector(initWithTextView:contextView:panGestureRecognizer:delegate:);
    class_replaceMethod([JSQMessagesKeyboardController class], allocSel, (IMP)emptyInitMethod, "@@:@@@@");
}


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([EVVoiceChatViewController class])
                          bundle:[NSBundle bundleForClass:[EVVoiceChatViewController class]]];
}

+ (instancetype)messagesViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([EVVoiceChatViewController class])
                                          bundle:[NSBundle bundleForClass:[EVVoiceChatViewController class]]];
}


- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.senderId = kSenderIdMe;
        self.senderDisplayName = kSenderDisplayNameMe;
        self.messages = [NSMutableArray array];
        [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:@"Test hello message"]];
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImage = [bubbleFactory outgoingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(FF, FF, FF, FF)];
        self.incomingBubbleImage = [bubbleFactory incomingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(03, A9, F4, FF)];
        [bubbleFactory release];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.collectionView.collectionViewLayout = [[[EVCollectionViewFlowLayout alloc] init] autorelease];
    //self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    for (NSString* path in self.viewSettings) {
        [self setValue:[self.viewSettings objectForKey:path] forKeyPath:path];
    }
    //self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topBarSizeConstraint.constant = (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? UI_BAR_HEIGHT_LANDSCAPE : UI_BAR_HEIGHT_PORTRAIT);
    self.topBarSizeConstraint.constant += [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIImage*)imageOfBackgroundView {
    UIGraphicsBeginImageContext(self.presentingViewController.view.bounds.size);
    [self.presentingViewController.view drawViewHierarchyInRect:self.presentingViewController.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [UIImageEffects imageByApplyingBlurToImage:image withRadius:20 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] saturationDeltaFactor:1.3 maskImage:nil];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    NSLog(@"Undo pressed!");
}

- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar didPressCenterBarButton:(UIButton *)sender {
    NSLog(@"Mic pressed!");
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(recordTimerFired:) userInfo:[NSMutableDictionary dictionaryWithDictionary:@{@"count": @0}] repeats:YES];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView newMinVolume:5.0f andMaxVolume:70.0f];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStarted];
}

- (void)recordTimerFired:(NSTimer *)timer {
    [timer.userInfo setObject:@([[timer.userInfo objectForKey:@"count"] integerValue]+1) forKey:@"count"];
    CGFloat val = (rand()%255)/4.5f+6.0f;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView newAudioLevelData:[NSData dataWithBytes:&val length:sizeof(CGFloat)]];
    if ([[timer.userInfo objectForKey:@"count"] integerValue] >= 40) {
        [timer invalidate];
        [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStoped];
        [(EVChatToolbarContentView *)self.inputToolbar.contentView startWaitAnimation];
        [self performSelector:@selector(myMessageSend) withObject:nil afterDelay:4.0f];
    }
}

- (void)myMessageSend {
    [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdMe displayName:kSenderDisplayNameMe text:@"Test my message"]];
    [self finishSendingMessageAnimated:YES];
    [self performSelector:@selector(getResponseMessage) withObject:nil afterDelay:2.0f];
}

- (void)getResponseMessage {
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
    [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:@"Test response message"]];
    [self finishReceivingMessageAnimated:YES];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    NSLog(@"Trash pressed!");
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messages count];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImage;
    }
    
    return self.incomingBubbleImage;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = RGBA_HEX_COLOR(F5, F5, F5, FF);
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped message: %@", [[self.messages objectAtIndex:indexPath.item] text]);
}

- (IBAction)hideChatView:(id)sender {
    self.openButton.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.openButton.hidden = YES;
    UIImageView* backView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backView.image = [self imageOfBackgroundView];
    [backView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:backView atIndex:0];
    [self.view jsq_pinAllEdgesOfSubview:backView];
    [backView release];
    [super viewWillAppear:animated];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)updateViewFromSettings:(NSDictionary*)settings {
    NSMutableDictionary *newSettings = [NSMutableDictionary dictionaryWithCapacity:[settings count]];
    NSMutableDictionary* pathRewrites = [[EVApplication sharedApplication] chatViewControllerPathRewrites];
    for (NSString* path in settings) {
        NSMutableString* newPath = [NSMutableString stringWithString:path];
        for (NSString* rewrite in pathRewrites) {
            [newPath replaceOccurrencesOfString:rewrite withString:[pathRewrites objectForKey:rewrite] options:0 range:NSMakeRange(0, [rewrite length]+1)];
        }
        id obj = [settings objectForKey:path];
        [newSettings setObject:obj forKey:newPath];
        [self setValue:obj forKeyPath:newPath];
    }
    
    self.viewSettings = newSettings;
}

@end
