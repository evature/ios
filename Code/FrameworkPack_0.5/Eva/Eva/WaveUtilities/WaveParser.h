//
//  WaveParser.h
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveInfo.h"

@interface WaveParser : NSObject

+(WaveParser *)parserWithSettings:(NSDictionary *)settings;
-(WaveInfo *)parseWaveFileAtPath:(NSString *)path error:(NSError **)error;

@end

