//
//  EVFlowElement.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

@implementation EVFlowElement

static NSDictionary* typeKeys = nil;
static NSMutableDictionary* childsRegistry = nil;

+ (void)load {
    typeKeys = [@{@"Other": @(EVFlowElementTypeOther),
                  @"Flight": @(EVFlowElementTypeFlight),
                  @"Hotel": @(EVFlowElementTypeHotel),
                  @"Car": @(EVFlowElementTypeCar),
                  @"Cruise": @(EVFlowElementTypeCruise),
                  @"Train": @(EVFlowElementTypeTrain),
                  @"Explore": @(EVFlowElementTypeExplore),
                  @"Question": @(EVFlowElementTypeQuestion),
                  @"Answer": @(EVFlowElementTypeAnswer),
                  @"Statement": @(EVFlowElementTypeStatement),
                  @"Service": @(EVFlowElementTypeService),
                  @"Reply": @(EVFlowElementTypeReply)
                  } retain];
    NSNumber* otherType = @(EVFlowElementTypeOther);
    childsRegistry = [[NSMutableDictionary alloc] initWithObjects:&self forKeys:&otherType count:1];
}

+ (EVFlowElementType)typeForTypeString:(NSString*)typeString {
    NSNumber* type = [typeKeys objectForKey:typeString];
    return type == nil ? EVFlowElementTypeOther : [type shortValue];
}

+ (instancetype)elementWithTypeString:(NSString*)typeString fromResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    return [self elementWithType:[self typeForTypeString:typeString] fromResponse:response andLocations:locations];
}

+ (instancetype)elementWithType:(EVFlowElementType)type fromResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    Class clazz = [childsRegistry objectForKey:@(type)];
    if (clazz == nil) {
        clazz = [childsRegistry objectForKey:@(EVFlowElementTypeOther)];
    }
    return [[[clazz alloc] initWithResponse:response andLocations:locations] autorelease];
}

+ (instancetype)elementWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    NSString* typeString = [response objectForKey:@"Type"];
    if (typeString == nil) {
        return nil;
    }
    return [self elementWithTypeString:typeString fromResponse:response andLocations:locations];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Type"] != nil) {
            NSNumber* val = [typeKeys objectForKey:[response objectForKey:@"Type"]];
            if (val != nil) {
                self.type = [val shortValue];
            } else {
                self.type = EVFlowElementTypeOther;
            }
        } else {
            self.type = EVFlowElementTypeOther;
        }
        self.sayIt = [response objectForKey:@"SayIt"];
        if ([response objectForKey:@"RelatedLocations"]) {
            NSMutableArray* relLocations = [NSMutableArray array];
            for (NSNumber* locIndex in [response objectForKey:@"RelatedLocations"]) {
                [relLocations addObject:[locations objectAtIndex:[locIndex unsignedIntegerValue]]];
            }
            self.relatedLocations = [NSArray arrayWithArray:relLocations];
        }
    }
    return self;
}

// Registration for Child classes
+ (void)registerClass:(Class)clazz forElementType:(EVFlowElementType)type {
    [childsRegistry setObject:clazz forKey:@(type)];
}

@end
