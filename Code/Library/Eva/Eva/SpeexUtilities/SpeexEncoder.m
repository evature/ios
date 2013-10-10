//
//  SpeexEncoder.m
//  SpeexEncodingDemo
//
//  Created by Mikhail Dudarev (mikejd@mikejd.ru) on 09.05.13.
//  Copyright (c) 2013 Mihteh Lab. All rights reserved.
//

#import "SpeexEncoder.h"
#import "WaveInfo.h"
#import "WaveParser.h"

#import <Ogg/Ogg.h>
#import <Speex/speex_header.h>
#import <Speex/speex_resampler.h>



@interface SpeexEncoder ()

//@property(retain,nonatomic) SpeexResamplerState *_spxResamplerState;

-(SpeexEncoder *)_initWithMode:(SpeexMode)mode quality:(SpeexQuality)quality outputSampleRate:(int)outSampleRate;

-(void)_spxCleanup;
-(void)_oggCleanup;
-(void)_spxSetup;
-(void)_oggSetup;

-(SpeexHeader)_makeSpeexHeader;
-(oggVorbisCommentStruct *)_makeOggVorbisComment;

-(void)_appendOggPageWithSpeexHeader:(SpeexHeader)speexHeader toMutableData:(NSMutableData *)mutableData;
-(void)_appendOggPageWithVorbisComment:(oggVorbisCommentStruct *)oggVorbisComment toMutableData:(NSMutableData *)mutableData;
-(void)_appendOggPageWithCompressedBits:(SpeexCompressedBits)compressedBits toMutableData:(NSMutableData *)mutableData;
-(void)_appendCurrentOggPageToMutableData:(NSMutableData *)mutableData;

@end

#pragma mark

@implementation SpeexEncoder {
    
                    int  _numberOfChannels;
               WaveInfo *_currentWaveInfo;
                NSError *_encodingError;
    
              SpeexBits  _spxBits;
                    char _spxCompressedBits[200];
          SpeexEncState *_spxEncoderState;
   SpeexResamplerState *_spxResamplerState;
                     int _spxSamplesPerFrame;
                    int  _spxBytesPerFrame;
                    int  _spxBitrate;
    
       ogg_stream_state  _oggStreamState;
                     int _oggVorbisCommentLength;
             ogg_packet  _oggPacket;
               ogg_page  _oggPage;
    
}


+(SpeexEncoder *)encoderWithMode:(SpeexMode)mode quality:(SpeexQuality)quality outputSampleRate:(SampleRate)outSampleRate {
    return [[SpeexEncoder alloc] _initWithMode:mode quality:quality outputSampleRate:outSampleRate];
}

-(NSData *)encodeWaveFileAtPath:(NSString *)path error:(NSError **)error {
    
    _encodingError = *error;
    NSMutableData *resultData = [NSMutableData dataWithCapacity:(100 * 1024)];
    
    // 1. PARSING WAVE FILE.
    
    _currentWaveInfo = [[WaveParser parserWithSettings:nil] parseWaveFileAtPath:path error:error];
    if (*error) { return nil; }
    
    // 2. SETTING UP SPEEX AND OGG TOOLS.
    
    [self _spxSetup];
    if (*error) { return nil; }
    
    [self _oggSetup];
    if (*error) { return nil; }
    
    // 3. RESAMPLING (QUICK & DIRTY SOLUTION; SHOULD BE REWRITTEN).
    
    const short *audioData = (const short *)[_currentWaveInfo.audioData bytes];
    unsigned int audioDataNumberOfSamples = _currentWaveInfo.numberOfSamples;
  /*
    unsigned int resampledAudioDataNumberOfSamples = audioDataNumberOfSamples * 1024;
    //short *resampledAudioData = calloc(sizeof(short), resampledAudioDataNumberOfSamples * _currentWaveInfo.bytesPerSample); // need to fix these calloc
    
    NSLog(@"audioDataNumberOfSamples=%d",audioDataNumberOfSamples);
    unsigned int len11 = 10 * 1024 * 1024;//40000;//512;
    short  buffer11[len11];//512];
	
	
    // speex_resampler_init(NUMBER_OF_CHANNELS_MONO, _currentWaveInfo.sampleRate.intValue, self.outSampleRate, SPEEX_RESAMPLER_QUALITY_MIN, &spxResamplerStateErr);
    
    speex_resampler_process_int(_spxResamplerState, 0, audioData, &audioDataNumberOfSamples, buffer11, &len11);
    NSData *resampledData = [NSData dataWithBytes:buffer11 length:len11 * _currentWaveInfo.bytesPerSample];*/
    

    //NSLog(@"_spxResamplerState=%@",_spxResamplerState );
    
    
    short *resampledAudioData = calloc(10 * 1024 * 1024, 2);
    unsigned int resampledAudioDataNumberOfSamples = audioDataNumberOfSamples * 1024;
    speex_resampler_process_int(_spxResamplerState, 0, audioData, &audioDataNumberOfSamples, resampledAudioData, &resampledAudioDataNumberOfSamples);
    NSData *resampledData = [NSData dataWithBytes:resampledAudioData length:resampledAudioDataNumberOfSamples * _currentWaveInfo.bytesPerSample];
    
    //NSData *resampledData = [NSData dataWithBytes:resampledAudioData length:resampledAudioDataNumberOfSamples * _currentWaveInfo.bytesPerSample];
    
    //free(resampledAudioData); // NEW //
    
    // Don't mind, that we alter waveInfo object here.
    _currentWaveInfo.sampleRate = [NSNumber numberWithInt:self.outSampleRate];
    _currentWaveInfo.audioData = resampledData;
    _currentWaveInfo.audioSize = resampledData.length;
    _currentWaveInfo.numberOfSamples = _currentWaveInfo.audioSize / _currentWaveInfo.bytesPerSample;
    
    
    // 4. WRITING TWO OGG PAGES WITH DEFAULT HEADERS.
    
    SpeexHeader spxHeader = [self _makeSpeexHeader];
    [self _appendOggPageWithSpeexHeader:spxHeader toMutableData:resultData];
    
    oggVorbisCommentStruct *oggVorbisComment = [self _makeOggVorbisComment];
    [self _appendOggPageWithVorbisComment:oggVorbisComment toMutableData:resultData];

    // 5. CALCULATING, HOW MANY FRAMES WE SHOULD GET.
    
    int numberOfCompleteFrames = [_currentWaveInfo numberOfCompleteFramesForFrameSize:_spxSamplesPerFrame];
    int numberOfRemainingSamples = [_currentWaveInfo numberOfRemainingSamplesForFrameSize:_spxSamplesPerFrame];

    // 6. ENCODING ITSELF, STAGE 1 (DEALING WITH COMPLETE FRAMES).
    
    for (int currentFrameIdx = 0; currentFrameIdx < numberOfCompleteFrames; currentFrameIdx++) {
        
        NSRange nextFrameRange = NSMakeRange(currentFrameIdx * _currentWaveInfo.bytesPerSample * _spxSamplesPerFrame, _currentWaveInfo.bytesPerSample * _spxSamplesPerFrame);
        NSData *nextFrameData = [_currentWaveInfo.audioData subdataWithRange:nextFrameRange];
        speex_bits_reset(&_spxBits);
        speex_encode_int(_spxEncoderState, (short *)nextFrameData.bytes, &_spxBits);
        int nextFrameCompressedBytesNumber = speex_bits_write(&_spxBits, _spxCompressedBits, _spxSamplesPerFrame);
        
        _oggPacket.packet = (unsigned char *)&_spxCompressedBits;
        _oggPacket.bytes = nextFrameCompressedBytesNumber;
        _oggPacket.granulepos = (currentFrameIdx + 1) * _spxSamplesPerFrame;
        _oggPacket.packetno = _oggStreamState.packetno;
        ogg_stream_packetin(&_oggStreamState, &_oggPacket);
        
        if ((currentFrameIdx + 1) % MAX_FRAMES_PER_OGG_PAGE == 0) {
            [self _appendCurrentOggPageToMutableData:resultData];
        }
    }

    // 7. ENCODING, STAGE 2 (DEALING WITH REMAINING SAMPLES).
    
    NSRange lastFrameRange = NSMakeRange(_currentWaveInfo.audioSize - numberOfRemainingSamples, numberOfRemainingSamples);
    NSMutableData *lastFrameData = [NSMutableData dataWithData:[_currentWaveInfo.audioData subdataWithRange:lastFrameRange]];
    int numberOfZeroBytesToAppend = _spxSamplesPerFrame - lastFrameData.length;
    char zeroBytesToAppend[numberOfZeroBytesToAppend];
    memset(zeroBytesToAppend, 0, sizeof(zeroBytesToAppend));
    [lastFrameData appendBytes:&zeroBytesToAppend length:sizeof(zeroBytesToAppend)];

    speex_bits_reset(&_spxBits);
    speex_encode_int(_spxEncoderState, (short *)lastFrameData.bytes, &_spxBits);
    int lastFrameCompressedBytesNumber = speex_bits_write(&_spxBits, _spxCompressedBits, _spxSamplesPerFrame);

    _oggPacket.packet = (unsigned char *)&_spxCompressedBits;
    _oggPacket.bytes = lastFrameCompressedBytesNumber;
    _oggPacket.granulepos = _currentWaveInfo.numberOfSamples;
    _oggPacket.packetno = _oggStreamState.packetno;
    _oggPacket.e_o_s = 1;

    [self _appendCurrentOggPageToMutableData:resultData];

    // 8. SORT OF CLEANING UP.
    
    [self _spxCleanup];
    [self _oggCleanup];
    
    // DONE!
    
    return [NSData dataWithData:resultData];
}

#pragma mark

-(SpeexEncoder *)_initWithMode:(SpeexMode)mode quality:(SpeexQuality)quality outputSampleRate:(int)outSampleRate {
    
    self = [super init];
    
    if (self) {
        _encodingMode = mode;
        _encodingQuality = quality;
        _outSampleRate = outSampleRate;
        _numberOfChannels = NUMBER_OF_CHANNELS_MONO;
    }
    
    return self;
}

-(void)_spxCleanup {
    if (_spxBits.nbBits > 0) {
        speex_bits_destroy(&_spxBits);
    }
    if (_spxEncoderState) {
        speex_encoder_destroy(_spxEncoderState);
    }
}

-(void)_oggCleanup {
    ogg_stream_clear(&_oggStreamState);
}

-(void)_spxSetup {
    
    [self _spxCleanup];
    
    speex_bits_init(&_spxBits);
    _spxEncoderState = speex_encoder_init(&_encodingMode);
    if (_spxEncoderState == NULL) {
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_COULD_ALLOCATE_ENCODER_STATE];
        return;
    }
    
    int spxResamplerStateErr;
    _spxResamplerState = speex_resampler_init(NUMBER_OF_CHANNELS_MONO, _currentWaveInfo.sampleRate.intValue, self.outSampleRate, SPEEX_RESAMPLER_QUALITY_MIN, &spxResamplerStateErr);
    //[_spxResamplerState retain];
   // NSLog(@"_spxResamplerState = %@",_spxResamplerState);
    NSLog(@"spxResamplerStateErr = %d",spxResamplerStateErr);
    if (spxResamplerStateErr != 0) {
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_COULD_NOT_SETUP_RESAMPLER];
        return;
    }
    
    int getFrameSizeErr = speex_encoder_ctl(_spxEncoderState, SPEEX_GET_FRAME_SIZE, &_spxSamplesPerFrame);
    if (getFrameSizeErr != 0) {
        
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_COULD_NOT_OBTAIN_FRAME_SIZE];
        return;
    }
    
    int getBitrateErr = speex_encoder_ctl(_spxEncoderState, SPEEX_GET_BITRATE, &_spxBitrate);
    if (getBitrateErr != 0) {
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_COULD_NOT_OBTAIN_BITRATE];
        return;
    }
    
    int setQualityErr = speex_encoder_ctl(_spxEncoderState, SPEEX_SET_QUALITY, &_encodingQuality);
    if (setQualityErr != 0) {
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_COULD_NOT_SET_QUALITY];
        return;
    }
}

-(void)_oggSetup {
    
    [self _oggCleanup];
    ogg_stream_init(&_oggStreamState, 1);
}

-(SpeexHeader)_makeSpeexHeader {
    
    SpeexHeader spxHeader;
    
    if (_spxBitrate == 0 || _spxSamplesPerFrame == 0) {
        _encodingError = [NSError errorWithCode:ERROR_CODE_SPEEX_ENCODER_NOT_ENOUGH_DATA_TO_CREATE_SPEEX_HEADER];
        return spxHeader;
    }
    
    speex_init_header(&spxHeader, self.outSampleRate, NUMBER_OF_CHANNELS_MONO, &_encodingMode);
    
    spxHeader.bitrate = _spxBitrate;
    spxHeader.frame_size = _spxSamplesPerFrame;
    spxHeader.frames_per_packet = 1;
    
    return spxHeader;
}

-(oggVorbisCommentStruct *)_makeOggVorbisComment {
    
    NSString *vendorString = @"****SpeexCommentVendorString****";
    int vendorStringLength = vendorString.length;
    oggVorbisCommentStruct *oggVorbisComment = calloc(sizeof(oggVorbisCommentStruct), sizeof(oggVorbisCommentStruct//char
                                                                                             ));
    NSData *vendorStringLengthData = [NSData dataWithBytes:&vendorStringLength length:4];
    
    for (int i = 0; i < vendorStringLengthData.length; i++) {
        oggVorbisComment->vendorStringLength[i] = *(char *)[[vendorStringLengthData subdataWithRange:NSMakeRange(i, 1)] bytes];
    }
    for (int i = 0; i < vendorStringLength; i++) {
        oggVorbisComment->vendorString[i] = *(const char *)[vendorString substringWithRange:NSMakeRange(i, 1)].UTF8String;
    }
    for (int i = 0; i < 4; i++) {
        oggVorbisComment->numberOfCommentFields[i] = 0x00;
    }
    
    _oggVorbisCommentLength = 4 + vendorStringLength + 4;
    
    return oggVorbisComment;
}

-(void)_appendOggPageWithSpeexHeader:(SpeexHeader)speexHeader toMutableData:(NSMutableData *)mutableData {
    int oggPacketSize;
    _oggPacket.packet = (unsigned char *)speex_header_to_packet(&speexHeader, &oggPacketSize);
    _oggPacket.bytes = oggPacketSize;
    _oggPacket.b_o_s = 1;
    _oggPacket.packetno = _oggStreamState.packetno;
    ogg_stream_packetin(&_oggStreamState, &_oggPacket);
    free(_oggPacket.packet);
    [self _appendCurrentOggPageToMutableData:mutableData];
}

-(void)_appendOggPageWithVorbisComment:(oggVorbisCommentStruct *)oggVorbisComment toMutableData:(NSMutableData *)mutableData {
    _oggPacket.packet = (unsigned char *)oggVorbisComment;
    _oggPacket.bytes = _oggVorbisCommentLength;
    _oggPacket.packetno = _oggStreamState.packetno;
    ogg_stream_packetin(&_oggStreamState, &_oggPacket);
    free(_oggPacket.packet);
    [self _appendCurrentOggPageToMutableData:mutableData];
}

-(void)_appendOggPageWithCompressedBits:(SpeexCompressedBits)compressedBits toMutableData:(NSMutableData *)mutableData {
    
}

-(void)_appendCurrentOggPageToMutableData:(NSMutableData *)mutableData {
    
    if (ogg_stream_pageout(&_oggStreamState, &_oggPage) == 0) {
        ogg_stream_flush(&_oggStreamState, &_oggPage);
    }
    
    [mutableData appendBytes:&_oggStreamState.header length:_oggStreamState.header_fill];
    [mutableData appendBytes:_oggStreamState.body_data length:_oggStreamState.body_fill];
}

@end