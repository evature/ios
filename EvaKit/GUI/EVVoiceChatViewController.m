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
#import "EVChatMessage.h"
#import "EVStatementFlowElement.h"
#import "EVReplyFlowElement.h"
#import "EVSearchResultsHandler.h"
#import <AVFoundation/AVFoundation.h>

static const char* kEVCollectionViewReloadDataKey = "kEVCollectionViewReloadDataKey";

#define RGBA_COLOR(_red, _green, _blue, _alpha) [UIColor colorWithRed:_red/255.0f green:_green/255.0f blue:_blue/255.0f alpha:_alpha/255.0f]
#define RGBA_HEX_COLOR(_red, _green, _blue, _alpha) RGBA_COLOR(0x##_red, 0x##_green, 0x##_blue, 0x##_alpha)

#define UI_BAR_HEIGHT_PORTRAIT 40
#define UI_BAR_HEIGHT_LANDSCAPE 32

#define EV_SPEECH_RATE 0.15f

#define COMBINE_VOICE_LEVELS_COUNT 2

#define EV_EVA_TEXT_COLOR RGBA_HEX_COLOR(F5, F5, F5, FF)

#define EV_UNDO_TUTORIAL @"Drag the microphone button to the left to undo the last utterance."

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

@interface EVVoiceChatViewController () {
    double minVolume;
    double maxVolume;
    double currentCombinedVolume;
    unsigned int currentCombinedVolumeCount;
    BOOL isRecording;
    BOOL _undoRequest;
    BOOL _shownWarningsTutorial;
    BOOL _isIOS9;
}

@property (nonatomic, strong) NSDictionary* viewSettings;
@property (nonatomic, assign) BOOL isNewSession;
@property (nonatomic, strong) EVSearchContext* oldContext;
@property (nonatomic, strong) AVSpeechSynthesizer* speechSynthesizer;

- (UIImage*)imageOfBackgroundView;
- (void)setHelloMessage;


// Eva response methods
- (void)handleFlowForResponse:(EVResponse*)response;
- (void)executeFlowElement:(EVFlowElement*)element forResponse:(EVResponse*)response andChatMessage:(EVChatMessage*)message;

- (void)showMyMessageForResponse:(EVResponse*)response hasWarnings:(BOOL*)hasWarnings;
- (void)showWarningMessage:(NSString*)message;
- (void)speakText:(NSString*)text;
- (void)stopSpeaking;

@end

@implementation EVVoiceChatViewController

@dynamic collectionView;
@dynamic inputToolbar;
@dynamic toolbarHeightConstraint;
@dynamic toolbarBottomLayoutGuide;


+ (void)initialize {
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
        self.senderId = [EVChatMessage clientID];
        self.senderDisplayName = [EVChatMessage clientDisplayName];
        self.startRecordingOnShow = NO;
        self.semanticHighlightingEnabled = YES;
        self.semanticHighlightLocations = YES;
        self.semanticHighlightTimes = YES;
        self.isNewSession = YES;
        self.speakEnabled = YES;
        isRecording = NO;
        _shownWarningsTutorial = NO;
        
        self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
        
        self.outgoingBubbleImage = [bubbleFactory outgoingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(FF, FF, FF, FF)];
        self.incomingBubbleImage = [bubbleFactory incomingMessagesBubbleImageWithColor:RGBA_HEX_COLOR(03, A9, F4, FF)];
        [bubbleFactory release];
        
        _isIOS9 = ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.99f);
       
        self.speechSynthesizer = [[AVSpeechSynthesizer new] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.viewSettings = nil;
    self.outgoingBubbleImage = nil;
    self.incomingBubbleImage = nil;
    self.oldContext = nil;
    [self stopSpeaking];
    self.speechSynthesizer = nil;
    [super dealloc];
}

- (void)setHelloMessage {
    NSString* message = nil;
    if ([self.delegate respondsToSelector:@selector(helloMessage)]) {
        message = [self.delegate helloMessage];
    } else {
        EVSearchContext* context = self.evApplication.context;
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
    }
    [self.evApplication.sessionMessages addObject:[EVChatMessage serverMessageWithID:self.evApplication.currentSessionID text:message]];
    [self speakText:message];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.collectionView.collectionViewLayout = [[[EVCollectionViewFlowLayout alloc] init] autorelease];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    for (NSString* path in self.viewSettings) {
        id obj = [self.viewSettings objectForKey:path];
        if ([obj isKindOfClass:[NSValue class]] && strcmp([(NSValue*)obj objCType], @encode(void*)) == 0) {
            obj = [obj nonretainedObjectValue];
        }
        [self setValue:obj forKeyPath:path];
    }
    self.oldContext = self.evApplication.context;
    self.evApplication.context = [EVSearchContext contextForDelegate:self.delegate];
    if (self.semanticHighlightingEnabled && !self.evApplication.highlightText) {
        self.semanticHighlightingEnabled = NO;
    }
    if ([self.evApplication.sessionMessages count] == 0) {
        [self setHelloMessage];
    }
    self.isNewSession = [self.evApplication.currentSessionID isEqualToString:EV_NEW_SESSION_ID];
    //self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (BOOL)isMyMessageInRow:(NSInteger)row {
    return [((EVChatMessage*)[self.evApplication.sessionMessages objectAtIndex:row]) isClientMessage];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topBarSizeConstraint.constant = (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? UI_BAR_HEIGHT_LANDSCAPE : UI_BAR_HEIGHT_PORTRAIT);
    self.topBarSizeConstraint.constant += [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
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
    [self stopSpeaking];
    [self.evApplication editLastQueryWithText:nil];
    _undoRequest = YES;
}

- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar didPressCenterBarButton:(UIButton *)sender {
    if (isRecording) {
        [self.evApplication stopRecording];
    } else {
        [self stopSpeaking];
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
    [self.evApplication.sessionMessages removeAllObjects];
    [self setHelloMessage];
    [self.collectionView reloadData];
    //[self.evApplication queryText:@"" withNewSession:self.isNewSession];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.evApplication.sessionMessages objectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.evApplication.sessionMessages count];
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
    
    cell.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    EVChatMessage *msg = [self.evApplication.sessionMessages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if (msg.attributedText != nil) {
            cell.textView.text = nil;
            cell.textView.attributedText = msg.attributedText;
        } else {
            cell.textView.attributedText = nil;
            cell.textView.text = msg.text;
        
        if ([msg isClientMessage]) {
            cell.textView.textColor = [UIColor blackColor];
        } else {
            cell.textView.textColor = EV_EVA_TEXT_COLOR;
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
        }
    } else {
        cell.textView.attributedText = nil;
    }
    
    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    EV_LOG_DEBUG(@"Tapped message: %@", [[self.evApplication.sessionMessages objectAtIndex:indexPath.item] text]);
}

- (IBAction)hideChatView:(id)sender {
    self.evApplication.context = self.oldContext;
    [self.evApplication hideChatViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIImageView* backView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backView.image = [self imageOfBackgroundView];
    [backView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:backView atIndex:0];
    [self.view jsq_pinAllEdgesOfSubview:backView];
    [backView release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    JSQMessagesCollectionViewFlowLayoutInvalidationContext* context = [JSQMessagesCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
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
            [newPath replaceOccurrencesOfString:rewrite withString:[pathRewrites objectForKey:rewrite] options:0 range:NSMakeRange(0, MIN([rewrite length]+1, [newPath length]))];
        }
        id obj = [settings objectForKey:path];
        [newSettings setObject:obj forKey:newPath];
    }
    self.viewSettings = newSettings;
}

- (void)showMyMessageForResponse:(EVResponse*)response hasWarnings:(BOOL*)hasWarnings {
    NSMutableAttributedString* chat = nil;
    if (response.processedText != nil && ![response.processedText isEqualToString:@""]) {
        // reply of voice -  add a "Me" chat item for the input text
        chat = [[[NSMutableAttributedString alloc] initWithString:response.processedText attributes:@{NSFontAttributeName: self.collectionView.collectionViewLayout.messageBubbleFont}] autorelease];
        if ([response.warnings count] > 0) {
            for (EVWarning* warning in response.warnings) {
                if (warning.position == -1 || warning.text == nil) {
                    continue;
                }
                *hasWarnings = YES;
                [chat addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternDot),
                                      NSUnderlineColorAttributeName:RGBA_COLOR(208.0f, 67.0f, 62.0f, 255.0f)}
                              range:NSMakeRange(warning.position, [warning.text length])
                 ];
            }
        }
        if (self.semanticHighlightingEnabled && response.parsedText != nil) {
            @try {
                if (self.semanticHighlightTimes && response.parsedText.times != nil) {
                    UIColor* highlightColor = RGBA_HEX_COLOR(4C, AF, 50, FF);
                    
                    for (EVTimesMarkup* time in response.parsedText.times) {
                        if (time.text == nil) {
                            continue;
                        }
                        [chat addAttribute:NSForegroundColorAttributeName value:highlightColor range:NSMakeRange(time.position, [time.text length])];
                    }
                }
                
                if (self.semanticHighlightLocations && response.parsedText.locations != nil) {
                    UIColor* highlightColor = RGBA_HEX_COLOR(03,A9,F4,FF);
                    
                    for (EVLocationMarkup* location in response.parsedText.locations) {
                        if (location.text == nil) {
                            continue;
                        }
                        [chat addAttribute:NSForegroundColorAttributeName value:highlightColor range:NSMakeRange(location.position, [location.text length])];
                    }
                }
            }
            @catch (NSException* e) {
                EV_LOG_ERROR(@"Error in setting spans of chat [%@]: %@", chat, e);
            }
        }
    }
    EVChatMessage* message = [EVChatMessage clientMessageWithText:[[[NSAttributedString alloc] initWithAttributedString:chat] autorelease]];
    [self.evApplication.sessionMessages addObject:message];
    [self finishSendingMessageAnimated:YES];
}


- (void)showWarningMessage:(NSString*)message {
    UIFont* font = [UIFont italicSystemFontOfSize:self.collectionView.collectionViewLayout.messageBubbleFont.pointSize];
    NSAttributedString* aS = [[[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: EV_EVA_TEXT_COLOR}] autorelease];
    EVChatMessage* cm = [EVChatMessage serverMessageWithID:self.evApplication.currentSessionID text:aS];
    [self.evApplication.sessionMessages addObject:cm];
    [self finishSendingMessageAnimated:YES];
}

- (void)speakText:(NSString *)text {
    if (self.speakEnabled && !isRecording) {
        AVSpeechUtterance* utterance = [AVSpeechUtterance speechUtteranceWithString:text];
        if (!_isIOS9) {
            utterance.rate = EV_SPEECH_RATE;
        }
        [self.speechSynthesizer speakUtterance:utterance];
    }
}
- (void)stopSpeaking {
    if (self.speechSynthesizer.speaking) {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

#pragma mark == EVA Search Methods ==

- (void)handleFlowForResponse:(EVResponse*)response {
    BOOL hasQuestion = false;
    for (EVFlowElement* flow in response.flow.flowElements) {
        if (flow.type == EVFlowElementTypeQuestion) {
            hasQuestion = true;
            break;
        }
    }
    
    BOOL first = true;
    
    // if there is a question - show and activate only statements and questions
    // otherwise - show all items and activate the first
    for (EVFlowElement* flow in response.flow.flowElements) {
        EVChatMessage* chatItem = nil;
        if (flow.type == EVFlowElementTypeQuestion) {
            EVChatMessage* questionChatItem = [EVChatMessage serverMessageWithID:response.transactionId text:flow.sayIt];
            chatItem = questionChatItem;
            [self.evApplication.sessionMessages addObject:chatItem];
            [self finishReceivingMessageAnimated:YES];
            
            [self executeFlowElement:flow forResponse:response andChatMessage:chatItem];
        } else {
            if (!hasQuestion || flow.type == EVFlowElementTypeStatement) {
                chatItem = [EVChatMessage serverMessageWithID:response.transactionId text:flow.sayIt];
                [self.evApplication.sessionMessages addObject:chatItem];
                [self finishReceivingMessageAnimated:YES];
                if (!hasQuestion && flow.type != EVFlowElementTypeStatement && first) {
                    first = false;
                    // activate only the first non-statement
                    [self executeFlowElement:flow forResponse:response andChatMessage:chatItem];
                }
            }
            if (flow.type == EVFlowElementTypeStatement) {
                [self executeFlowElement:flow forResponse:response andChatMessage:chatItem];
            }
        }
    }
}

- (void)executeFlowElement:(EVFlowElement*)element forResponse:(EVResponse*)response andChatMessage:(EVChatMessage*)message {
    
    NSString* sayIt = [element sayIt];
    if (sayIt != nil && ![sayIt isEqualToString:@""]) {
        [self speakText:sayIt];
    }
    
    switch (element.type) {
        case EVFlowElementTypeReply: {
            EVReplyFlowElement* replyElement = (EVReplyFlowElement*)element;
            if ([EVServiceAttributesCallSupport isEqualToString:replyElement.attributeKey]) {
                // TODO: trigger call support
            }
            break;
        }
        case EVFlowElementTypeFlight:
        case EVFlowElementTypeCar:
        case EVFlowElementTypeHotel:
        case EVFlowElementTypeExplore:
        case EVFlowElementTypeTrain:
        case EVFlowElementTypeCruise:
        case EVFlowElementTypeQuestion:
            [EVSearchResultsHandler handleSearchResultWithResponse:response flow:element responseDelegate:self.delegate andMessageHandler:^(EVSearchModel *response, BOOL complete) {
                message.searchModel = response;
            }];
            break;
            
        case EVFlowElementTypeStatement: {
            EVStatementFlowElement* se = (EVStatementFlowElement*)element;
            switch (se.statementType) {
                case EVStatementFlowElementTypeUnderstanding:
                case EVStatementFlowElementTypeUnknownExpression:
                case EVStatementFlowElementTypeUnsupported: {
                    _shownWarningsTutorial = YES;
                    [self showWarningMessage:EV_UNDO_TUTORIAL];
                    break;
                }
                case EVStatementFlowElementTypeChat:
                    if (response.originalInputText != nil && [[response.originalInputText lowercaseString] isEqualToString:@"bye bye"]) {
                        [self hideChatView:self];
                    }
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            EV_LOG_INFO("Unexpected flow type %d", element.type);
            break;
    }
}


#pragma mark == EVApplication delegate ===
- (void)evApplication:(EVApplication*)application didObtainResponse:(EVResponse*)response {
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView setUserInteractionEnabled:YES];
    
    if (response.isNewSession) {
        [self.evApplication.sessionMessages removeAllObjects];
    }
    
    BOOL hasWarnings = NO;
    
    if (_undoRequest) {
        NSMutableArray* messages = self.evApplication.sessionMessages;
        NSUInteger count = [messages count];
        NSInteger i;
        for (i = count-3; i >= 0; i--) {
            if (![self isMyMessageInRow:i]) {
                break;
            }
        }
        i = i < 0 ? 0 : i;
        [messages removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, count-i)]];
        [self.collectionView reloadData];
        _undoRequest = NO;
    } else {
        [self showMyMessageForResponse:response hasWarnings:&hasWarnings];
    }
    
    if (response.flow != nil) {
        [response retain];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [response autorelease];
            [self handleFlowForResponse:response];
            
            if (hasWarnings && !_shownWarningsTutorial) {
                _shownWarningsTutorial = YES;
                [self showWarningMessage:EV_UNDO_TUTORIAL];
            }
            
            if ([self.delegate respondsToSelector:@selector(evSearchGotResponse:)]) {
                [self.delegate evSearchGotResponse:response];
            }
        });
    }
}

- (void)evApplication:(EVApplication*)application didObtainError:(NSError*)error {
    EV_LOG_ERROR(@"%@", error);
    _undoRequest = NO;
    [(EVChatToolbarContentView *)self.inputToolbar.contentView audioSessionStoped];
    [(EVChatToolbarContentView *)self.inputToolbar.contentView stopWaitAnimation];
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        [self.evApplication.sessionMessages addObject:[EVChatMessage serverMessageWithID:self.evApplication.currentSessionID text:@"Connection error."]];
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
