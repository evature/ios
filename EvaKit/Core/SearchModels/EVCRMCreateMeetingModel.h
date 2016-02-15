//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMDataDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMCreateMeetingModel : EVSearchModel

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, strong, readonly) NSNumber* duration;
@property (nonatomic, strong, readonly) NSString* subject;
@property (nonatomic, strong, readonly) NSArray* participants;

- (instancetype)initWithComplete:(BOOL)isComplete
                            date:(NSDate*)date
                        duration:(NSNumber*)duration
                         subject:(NSString*)subject
                    participants:(NSArray*)participants;

+ (instancetype)modelComplete:(BOOL)isComplete
                         date:(NSDate*)date
                     duration:(NSNumber*)duration
                      subject:(NSString*)subject
                 participants:(NSArray*)participants;



@end
