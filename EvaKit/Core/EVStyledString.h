//
//  EVStyledString.h
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVStyledString : NSObject

@property (nonatomic, assign, readonly) BOOL hasStyle;

+ (instancetype)styledStringWithString:(NSString*)aString;
+ (instancetype)styledStringWithAttributedString:(NSAttributedString*)aString;

- (instancetype)initWithString:(NSString*)aString;
- (instancetype)initWithAttributedString:(NSAttributedString*)aString;

- (NSString*)string;
- (NSAttributedString*)attributedString;

-(id)copyWithZone:(NSZone*)zone;

@end
