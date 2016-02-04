//
//  EVFlowElement.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVLocation.h"


typedef NS_ENUM(int16_t, EVFlowElementType) {
    EVFlowElementTypeOther = -1,
    EVFlowElementTypeFlight = 0,
    EVFlowElementTypeHotel,
    EVFlowElementTypeCar,
    EVFlowElementTypeCruise,
    EVFlowElementTypeTrain,
    EVFlowElementTypeExplore,
    
    EVFlowElementTypeNavigate,
    EVFlowElementTypePhone,
    EVFlowElementTypeQuestion,
    EVFlowElementTypeAnswer,
    EVFlowElementTypeStatement,
    EVFlowElementTypeService,
    EVFlowElementTypeReply,
    EVFlowElementTypeData
};

@interface EVFlowElement : NSObject

@property (nonatomic, strong, readwrite) NSString* sayIt;
@property (nonatomic, strong, readwrite) NSArray* relatedLocations;
@property (nonatomic, assign, readwrite) EVFlowElementType type;

+ (instancetype)elementWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations;

+ (instancetype)elementWithType:(EVFlowElementType)type fromResponse:(NSDictionary*)response andLocations:(NSArray*)locations;
+ (instancetype)elementWithTypeString:(NSString*)typeString fromResponse:(NSDictionary*)response andLocations:(NSArray*)locations;

+ (EVFlowElementType)typeForTypeString:(NSString*)typeString;

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations;

// Registration for Child classes
+ (void)registerClass:(Class)clazz forElementType:(EVFlowElementType)type;

@end
