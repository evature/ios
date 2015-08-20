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

static const char* kEVCollectionViewReloadDataKey = "kEVCollectionViewReloadDataKey";

#define RGBA_COLOR(_red, _green, _blue, _alpha) [UIColor colorWithRed:_red/255.0f green:_green/255.0f blue:_blue/255.0f alpha:_alpha/255.0f]
#define RGBA_HEX_COLOR(_red, _green, _blue, _alpha) RGBA_COLOR(0x##_red, 0x##_green, 0x##_blue, 0x##_alpha)

#define UI_BAR_HEIGHT_PORTRAIT 40
#define UI_BAR_HEIGHT_LANDSCAPE 32

#define COMBINE_VOICE_LEVELS_COUNT 2

typedef void (*R_IMP)(void*, SEL);
R_IMP oldReloadData;

id emptyInitMethod(id lookupObject, SEL selector, id pr1, id p2, id p3, id p4) {
    [lookupObject init];
    [lookupObject release];
    return nil;
}

void reloadData(id collectionView, SEL selector) {
    if (![objc_getAssociatedObject(collectionView, kEVCollectionViewReloadDataKey) boolValue]) {
        objc_setAssociatedObject(collectionView, kEVCollectionViewReloadDataKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [collectionView performBatchUpdates:^{
            [collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished){
            if (finished) {
                objc_setAssociatedObject(collectionView, kEVCollectionViewReloadDataKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }];
    } else {
        oldReloadData(collectionView, selector);
    }
}

NSString* const kSenderIdMe = @"me";
NSString* const kSenderDisplayNameMe = @"Me";
NSString* const kSenderIdEva = @"eva";
NSString* const kSenderDisplayNameEva = @"Eva";

@interface EVVoiceChatViewController () {
    double minVolume;
    double maxVolume;
    double currentCombinedVolume;
    unsigned int currentCombinedVolumeCount;
    BOOL isRecording;
}

@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSDictionary* viewSettings;
@property (nonatomic, assign) BOOL isNewSession;
@property (nonatomic, strong) EVSearchContext* oldContext;

- (UIImage*)imageOfBackgroundView;
- (void)setHelloMessage;

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
    
    SEL reloadDataSel = @selector(reloadData);
    oldReloadData = (R_IMP)class_replaceMethod([JSQMessagesCollectionView class], reloadDataSel, (IMP)reloadData, "v@:");
    if (oldReloadData == NULL) {
        oldReloadData = (R_IMP)class_getMethodImplementation([UICollectionView class], reloadDataSel);
    }
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
        self.startRecordingOnShow = NO;
        self.isNewSession = YES;
        isRecording = NO;
        self.messages = [NSMutableArray array];
        
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImage = [bubbleFactory outgoingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(FF, FF, FF, FF)];
        self.incomingBubbleImage = [bubbleFactory incomingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(03, A9, F4, FF)];
        [bubbleFactory release];
        
    }
    return self;
}

- (void)setHelloMessage {
    EVSearchContext* context = self.evApplication.context;
    NSString* message = nil;
    switch (context.type) {
        case EVSearchContextTypeFlight:
            message = @"What flight can I find for you?";
            break;
        case EVSearchContextTypeCruise:
            message = @"What cruise can I find for you?";
            break;
        case EVSearchContextTypeCar:
            message = @"What car can I find for you?";
            break;
        case EVSearchContextTypeHotel:
            message = @"What hotel can I find for you?";
            break;
        default:
            message = @"Hello, how may I help you?";
            break;
    }
    [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:message]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.collectionView.collectionViewLayout = [[[EVCollectionViewFlowLayout alloc] init] autorelease];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    for (NSString* path in self.viewSettings) {
        [self setValue:[self.viewSettings objectForKey:path] forKeyPath:path];
    }
    self.oldContext = self.evApplication.context;
    self.evApplication.context = [EVSearchContext contextForDelegate:self.delegate];
    [self setHelloMessage];
    //self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (BOOL)isMyMessageInRow:(NSInteger)row {
    return [((JSQMessage*)[self.messages objectAtIndex:row]).senderId isEqualToString:self.senderId];
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
    EV_LOG_DEBUG(@"Undo pressed!");
    [self.evApplication editLastQueryWithText:nil];
}

- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar didPressCenterBarButton:(UIButton *)sender {
    if (isRecording) {
        [self.evApplication stopRecording];
    } else {
        minVolume = DBL_MAX;
        maxVolume = DBL_MIN;
        currentCombinedVolume = 0.0;
        currentCombinedVolumeCount = 0;
        [self.evApplication startRecordingWithNewSession:self.isNewSession];
        self.isNewSession = NO;
    }
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:NO];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    EV_LOG_DEBUG(@"Trash pressed!");
    self.isNewSession = YES;
    [self.messages removeAllObjects];
    [self setHelloMessage];
    [self.collectionView reloadData];
    //[self.evApplication queryText:@"" withNewSession:self.isNewSession];
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
    
    return [self isMyMessageInRow:indexPath.item] ? self.outgoingBubbleImage : self.incomingBubbleImage;
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
    EV_LOG_DEBUG(@"Tapped message: %@", [[self.messages objectAtIndex:indexPath.item] text]);
}

- (IBAction)hideChatView:(id)sender {
    self.evApplication.context = self.oldContext;
    [self.evApplication hideChatViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    UIImageView* backView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backView.image = [self imageOfBackgroundView];
    [backView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:backView atIndex:0];
    [self.view jsq_pinAllEdgesOfSubview:backView];
    [backView release];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.startRecordingOnShow) {
        [self messagesInputToolbar:((EVChatToolbarView*)self.inputToolbar) didPressCenterBarButton:nil];
    }
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

#pragma mark == EVApplication delegate ===
- (void)evApplication:(EVApplication*)application didObtainResponse:(EVResponse*)response {
    
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:YES];
    
    
    [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdMe displayName:kSenderDisplayNameMe text:response.processedText]];
    [self finishSendingMessageAnimated:YES];
        
    
    if ([response.flow.flowElements count] > 0) {
        [response retain];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [response autorelease];
            EVFlowElement* element = [response.flow.flowElements objectAtIndex:0];
            [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:element.sayIt]];
            [self finishReceivingMessageAnimated:YES];
            if ([self.delegate respondsToSelector:@selector(evSearchGotResponse:)]) {
                [self.delegate evSearchGotResponse:response];
            }
        });
    }
}
- (void)evApplication:(EVApplication*)application didObtainError:(NSError*)error {
    EV_LOG_ERROR(@"%@", error);
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStoped];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        [self.messages addObject:[JSQMessage messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:@"Connection error."]];
        [self finishReceivingMessageAnimated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(evSearchGotAnError:)]) {
        [self.delegate evSearchGotAnError:error];
    }
}

- (void)evApplicationIsReady:(EVApplication *)application {
    isRecording = NO;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:YES];
}

- (void)evApplicationRecordingIsCancelled:(EVApplication *)application {
    isRecording = NO;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:YES];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStoped];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
}

- (void)evApplicationRecordingIsStarted:(EVApplication *)application {
    isRecording = YES;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStarted];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:YES];
    });
}

- (void)evApplicationRecordingIsStoped:(EVApplication *)application {
    EV_LOG_DEBUG(@"Record stoped!");
    isRecording = NO;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:NO];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStoped];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView startWaitAnimation];
}

- (void)evApplication:(EVApplication*)application recordingVolumePeak:(float)peak andAverage:(float)average {
    
    double current = pow(10, (0.05 * average));
    currentCombinedVolume += current;
    
    if (++currentCombinedVolumeCount >= COMBINE_VOICE_LEVELS_COUNT) {
        CGFloat val = currentCombinedVolume / currentCombinedVolumeCount;
        currentCombinedVolumeCount = 0;
        currentCombinedVolume = 0.0;
        [(EVChatToolbarContentView *)self.inputToolbar.contentView newAudioLevelData:[NSData dataWithBytes:&val length:sizeof(CGFloat)]];
    }
    
    maxVolume = (current > maxVolume) ? current : maxVolume;
    minVolume = (current < minVolume) ? current : minVolume;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView newMinVolume:minVolume andMaxVolume:maxVolume];
    
}

@end
