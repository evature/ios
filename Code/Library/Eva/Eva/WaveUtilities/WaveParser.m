//
//  WaveParser.m
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import "WaveParser.h"
#import "NSError+CustomError.h"
#include <libkern/OSByteOrder.h>

@interface WaveParser ()

-(WaveParser *)initWithSettings:(NSDictionary *)settings;

// Быстрая проверка файла на формат и целостность.
-(BOOL)quickCheckWaveFile;
-(BOOL)quickCheckWaveFileSize;
-(BOOL)quickCheckWaveFileContainerId;
-(BOOL)quickCheckWaveFileFormatId;

// Извлечение метаданных и аудиоданных.
-(BOOL)extractInfo;
-(BOOL)extractInfoDataChunkIdPosition;
-(BOOL)extractInfoAudioProperties;

@end

@implementation WaveParser {
      NSData *_waveData;
    WaveInfo *_waveInfo;
     NSError *_error;
}

#pragma mark - Init.

+(WaveParser *)parserWithSettings:(NSDictionary *)settings {
    return [[WaveParser alloc] initWithSettings:settings];
}

-(WaveParser *)initWithSettings:(NSDictionary *)settings {
    
    self = [super init];
    
    if (self) {
        // ... (set settings)
    }
    
    return self;
}

#pragma mark -

-(WaveInfo *)parseWaveFileAtPath:(NSString *)path error:(NSError **)error {
    
    _waveData = [NSData dataWithContentsOfFile:path];
    _error =  *error;
    
    if (![self quickCheckWaveFile]) {
        return nil;
    }

    if (![self extractInfo]) {
        return nil;
    }
    
    _error = nil;
    return _waveInfo;
}

#pragma mark - Быстрая проверка файла.

-(BOOL)quickCheckWaveFile {
    if (![self quickCheckWaveFileSize]) {
        _error = [NSError errorWithCode:ERROR_CODE_WAVE_PARSER_INCORRECT_FILESIZE];
        return NO;
    } else if (![self quickCheckWaveFileContainerId]) {
        _error = [NSError errorWithCode:ERROR_CODE_WAVE_PARSER_CONTAINER_ID_NOT_FOUND];
        return NO;
    } else if (![self quickCheckWaveFileFormatId]) {
        _error = [NSError errorWithCode:ERROR_CODE_WAVE_PARSER_FORMAT_ID_NOT_FOUND];
        return NO;
    } else {
        _error = nil;
        return YES;
    }
}

-(BOOL)quickCheckWaveFileSize {
    // ChunkSize field contains the size of the entire file in bytes minus 8 bytes
    // for the two fields not included in this count: ChunkID and the ChunkSize itself.
    NSData *sizeFieldData = [_waveData subdataWithRange:NSMakeRange(4, 8)];
    unsigned long partialSize = OSSwapHostToLittleInt32( *(unsigned long *)[sizeFieldData bytes] );
    unsigned long totalSize = partialSize + 8;
    return (totalSize == _waveData.length);
}

-(BOOL)quickCheckWaveFileContainerId {
    NSData *containerIdFieldData = [_waveData subdataWithRange:NSMakeRange(0, 4)];
    NSString *containerIdFieldString = [[NSString alloc] initWithData:containerIdFieldData encoding:NSUTF8StringEncoding];
    return ([containerIdFieldString isEqualToString:@"RIFF"]);
}

-(BOOL)quickCheckWaveFileFormatId {
    NSData *formatFieldData = [_waveData subdataWithRange:NSMakeRange(8, 4)];
    NSString *formatFieldString = [[NSString alloc] initWithData:formatFieldData encoding:NSUTF8StringEncoding];
    return ([formatFieldString isEqualToString:@"WAVE"]);
}

#pragma mark - Извлечение данных из файла.

-(BOOL)extractInfo {
    _waveInfo = [[WaveInfo alloc] init];
    if (![self extractInfoDataChunkIdPosition]) {
        _error = [NSError errorWithCode:ERROR_CODE_WAVE_PARSER_DATA_CHUNK_ID_NOT_FOUND];
        return NO;
    } else if (![self extractInfoAudioProperties]) {
        _error = [NSError errorWithCode:ERROR_CODE_WAVE_PARSER_AUDIO_PROPERTIES_NOT_EXTRACTED];
        return NO;
    } else {
        _error = nil;
        return YES;
    }
}

-(BOOL)extractInfoDataChunkIdPosition {
    
    // Here we assume that fmt chunk is the first one, immediately foloowing the header.
    int searchStartPosition = 36;
    
    // In RIFF container there's no particular rigid order of chunks, so in theory data chunk can start anywhere.
    // Nevertheless, for the sake of performance, we restrict search to some limit.
    int searchLimit = 10 * 1024;
    searchLimit = (searchLimit > _waveData.length - 3) ? _waveData.length - 3 : searchLimit;
    
    for (int i = searchStartPosition; i < searchLimit; i++) {
        NSString *string = [[NSString alloc] initWithData:[_waveData subdataWithRange:NSMakeRange(i, 4)] encoding:NSUTF8StringEncoding];
        if ([string.lowercaseString isEqualToString:@"data"]) {
            _waveInfo.dataChunkIdPosition = [NSNumber numberWithInt:i];
            return YES;
        }
    }
    return NO;
}

-(BOOL)extractInfoAudioProperties {
    // Again, we assume that fmt subchunk starts after 12 bytes from the beginning of file.
    NSData *sampleRateData = [_waveData subdataWithRange:NSMakeRange(24, 4)];
    NSData *bitDepthData = [_waveData subdataWithRange:NSMakeRange(34, 2)];
    NSData *audioSizeData = [_waveData subdataWithRange:NSMakeRange(_waveInfo.dataChunkIdPosition.intValue + 4, 4)];
    _waveInfo.sampleRate = [NSNumber numberWithInt:*(int *)sampleRateData.bytes];
    _waveInfo.bitsPerSample = *(int *)bitDepthData.bytes;
    _waveInfo.bytesPerSample = _waveInfo.bitsPerSample / 8;
    _waveInfo.audioSize = *(int *)audioSizeData.bytes;
    _waveInfo.audioData = [_waveData subdataWithRange:NSMakeRange(_waveInfo.dataChunkIdPosition.intValue + 8, _waveInfo.audioSize)];
    _waveInfo.numberOfSamples = _waveInfo.audioSize / _waveInfo.bytesPerSample; // remember, that audiosize is in bytes
    return YES;
}

@end
