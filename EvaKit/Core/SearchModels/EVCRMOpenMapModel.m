//
//  EvaKit
//
//  Copyright (c) 2016 Evature. All rights reserved.
//

#import "EVCRMOpenMapModel.h"
#import "EVCRMPhoneActionDelegate.h"

@interface EVCRMOpenMapModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;

@end

@implementation EVCRMOpenMapModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage{
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.subPage = subPage;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                   subPage:subPage] autorelease];
}



- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(openMap:withId:)]) {
        return [(id<EVCRMPhoneActionDelegate>)delegate openMap:self.page withId:self.subPage];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.subPage = nil;
    [super dealloc];
}

@end
