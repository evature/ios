//
//  EVViewControllerVisibilityObserver.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/23/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVViewControllerVisibilityObserver.h"
#import <objc/runtime.h>

static const char *kAssociatedVisibilityObserver = "kAssociatedEVVisibilityObserver";
typedef void (*WILL_IMP)(void*, SEL, BOOL);
typedef void (*DELL_IMP)(void*, SEL);

@interface EVViewControllerVisibilityObserver ()

@property (nonatomic, assign, readwrite) UIViewController* controller;
@property (nonatomic, assign, readwrite) id<EVViewControllerVisibilityObserverDelegate> delegate;

@end

WILL_IMP originalWillAppear;
WILL_IMP originalWillDisappear;
DELL_IMP originalDealloc;

void rplWillAppear(id self, SEL _cmd, BOOL animated) {
    EVViewControllerVisibilityObserver *obsrv = objc_getAssociatedObject(self, kAssociatedVisibilityObserver);
    if (obsrv != nil) {
        [obsrv.delegate controllerWillShow:self];
    }
    originalWillAppear(self, _cmd, animated);
}

void rplWillDissapear(id self, SEL _cmd, BOOL animated) {
    EVViewControllerVisibilityObserver *obsrv = objc_getAssociatedObject(self, kAssociatedVisibilityObserver);
    if (obsrv != nil) {
        [obsrv.delegate controllerDidHide:self];
    }
    originalWillDisappear(self, _cmd, animated);
}

void rplDealloc(id self, SEL _cmd) {
    EVViewControllerVisibilityObserver *obsrv = objc_getAssociatedObject(self, kAssociatedVisibilityObserver);
    if (obsrv != nil) {
        [obsrv.delegate controllerWillRemove:self];
    }
    originalDealloc(self, _cmd);
}

@implementation EVViewControllerVisibilityObserver

+ (void)initialize {
    Method willAppear = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"viewWillAppear:"));
    originalWillAppear = (WILL_IMP)class_replaceMethod([UIViewController class], NSSelectorFromString(@"viewWillAppear:"), (IMP)rplWillAppear, method_getTypeEncoding(willAppear));
    
    Method willDissapear = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"viewWillDisappear:"));
    originalWillDisappear = (WILL_IMP)class_replaceMethod([UIViewController class], NSSelectorFromString(@"viewWillDisappear:"), (IMP)rplWillDissapear, method_getTypeEncoding(willDissapear));
    
    Method dealloc = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"));
    originalDealloc = (DELL_IMP)class_replaceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), (IMP)rplDealloc, method_getTypeEncoding(dealloc));
}

- (instancetype)initWithController:(UIViewController *)controller andDelegate:(id<EVViewControllerVisibilityObserverDelegate>)delegate {
    self = [super init];
    if (self != nil) {
        self.controller = controller;
        self.delegate = delegate;
        objc_setAssociatedObject(controller, kAssociatedVisibilityObserver, self, OBJC_ASSOCIATION_ASSIGN);
    }
    return self;
}

- (void)dealloc {
    objc_setAssociatedObject(self.controller, kAssociatedVisibilityObserver, nil, OBJC_ASSOCIATION_ASSIGN);
    [super dealloc];
}


@end
