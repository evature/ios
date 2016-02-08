//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMPhoneModel.h"
#import "EVCRMPhoneDelegate.h"

@interface EVCRMPhoneModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, assign, readwrite) EVCRMPhoneType phoneType;
@property (nonatomic, strong, readwrite) NSString* subPage;

@end

@implementation EVCRMPhoneModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                       phoneType:(EVCRMPhoneType)phoneType {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.subPage = subPage;
        self.phoneType = phoneType;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                    phoneType:(EVCRMPhoneType)phoneType {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                   subPage:subPage
                                  phoneType:phoneType] autorelease];
}



- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMPhoneDelegate)]) {
        return [(id<EVCRMPhoneDelegate>)delegate phoneCall:self.page withId:self.subPage withPhoneType:self.phoneType];
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.subPage = nil;
    [super dealloc];
}

@end
