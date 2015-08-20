//
//  EVTravelers.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVTravelers : NSObject

// -1 means it wasn't specified by the user,  0 means it was explicitly specified to zero by the user
@property (nonatomic, assign, readwrite) NSInteger adult;
@property (nonatomic, assign, readwrite) NSInteger child;
@property (nonatomic, assign, readwrite) NSInteger infant;
@property (nonatomic, assign, readwrite) NSInteger elderly;

- (instancetype)initWithResponse:(NSDictionary *)response;


/***
 * @return Integer number of children (not infants!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedChildren;

/***
 * @return Integer number of elderly (not adults!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedElderly;

/***
 * @return Integer number of infants (not children!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedInfants;

/***
 * @return Total number of adults (adult+elderly) - if none are specified the result is zero
 */
- (NSInteger)getAllAdults;

/***
 * @return Total number of children (children+infants) - if none are specified the result is zero
 */
- (NSInteger)getAllChildren;

- (NSInteger)getAdults;
- (NSInteger)getChildren;

- (NSInteger)getElderly;
- (NSInteger)getInfants;


@end
