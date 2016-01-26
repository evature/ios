//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMDataGetModel.h"
#import "EVCRMDataGetDelegate.h"

@interface EVCRMDataGetModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;
@property (nonatomic, strong, readwrite) NSString* field;

@end

@implementation EVCRMDataGetModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                        setField:(NSString*)field {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.subPage = subPage;
        self.field = field;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                     setField:(NSString*)field {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                   subPage:subPage
                                  setField:field
                               ] autorelease];
}



- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMDataGetDelegate)]) {
        return [(id<EVCRMDataGetDelegate>)delegate getField:self.field
                                            inPage:(EVCRMPageType)self.page
                                              withId:self.subPage
                                             ];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.field = nil;
    self.subPage = nil;
    [super dealloc];
}

@end
