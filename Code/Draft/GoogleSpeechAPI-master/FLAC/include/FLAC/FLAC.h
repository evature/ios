//
//  FLAC.h
//  FLAC
//
//  Created by hayashi on 1/30/13.
//  Copyright (c) 2013 hayashi. All rights reserved.
//

#ifndef __FLAC_FLAC_H__
#define __FLAC_FLAC_H__

#include <stdint.h>

#ifdef __cplusplus
extern "C"{
#endif

	typedef struct FLACPCMInput{
		int32_t *data;
		int      sampleCount;
		int      channels;
		int      sampleRate;
		int      bitsPerSample;
	}FLACPCMInput;
	
	FLACPCMInput* FLACPCMInputAlloc(int sampleCount,int channels);
	void FLACPCMInputRelease(FLACPCMInput *input);
	
	int  FLACEncodeToFile(FLACPCMInput *input, const char *dstPath);
	int  FLACEncodeToStream(FLACPCMInput *input,void **bytes, int *length);


#ifdef __cplusplus
}
#endif
		
#endif
