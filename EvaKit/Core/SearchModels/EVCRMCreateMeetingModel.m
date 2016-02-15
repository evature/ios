//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMCreateMeetingModel.h"
#import "EVCRMDataDelegate.h"

@interface EVCRMCreateMeetingModel ()

@property (nonatomic, strong, readwrite) NSDate* date;
@property (nonatomic, strong, readwrite) NSNumber* duration;
@property (nonatomic, strong, readwrite) NSString* subject;
@property (nonatomic, strong, readwrite) NSArray* participants;

@end

@implementation EVCRMCreateMeetingModel


- (instancetype)initWithComplete:(BOOL)isComplete
                            date:(NSDate*)date
                        duration:(NSNumber*)duration
                         subject:(NSString*)subject
                    participants:(NSArray*)participants {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.date = date;
        self.duration = duration;
        self.subject = subject;
        self.participants = participants;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                         date:(NSDate*)date
                     duration:(NSNumber*)duration
                      subject:(NSString*)subject
                 participants:(NSArray*)participants {

    return [[[self alloc] initWithComplete:isComplete
                                      date:date
                                  duration:duration
                                   subject:subject
                              participants:participants] autorelease];
}



- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(createMeetingOnDate:withDuration:withSubject:withParticipants:)]) {
        return [(id<EVCRMDataDelegate>)delegate createMeetingOnDate:self.date withDuration:self.duration withSubject:self.subject withParticipants:self.participants];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.date = nil;
    self.duration = nil;
    self.subject = nil;
    self.participants = nil;
    [super dealloc];
}

@end
