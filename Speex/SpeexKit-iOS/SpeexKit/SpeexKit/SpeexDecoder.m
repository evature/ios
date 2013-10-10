//
//  SpeexDecoder.m
//  SpeexKit
//
//  Created by Ryan Wang on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeexDecoder.h"
#include "speexdec.c"

#define MAX_FRAME_SIZE 2000

@implementation SpeexDecoder

+ (NSString *)version {
    const char* speex_version;
    speex_lib_ctl(SPEEX_LIB_GET_VERSION_STRING, (void*)&speex_version);

    return [NSString stringWithFormat:@"%s",speex_version];
}

+ (NSString *)longVersion {
    NSString *version = [self version];
    
    NSString *longVersion = [NSString stringWithFormat:@"\
                             speexdec (Speex decoder) version %@\n\
                             Copyright (C) 2002-2006 Jean-Marc Valin\n", version
                             ];
 
    return longVersion;
}

- (id)initWithEncodedFile:(NSString *)filePath delegate:(id)aDelegate {
    if (self = [super init]) {
        _delegate = aDelegate;
//        NSStream
//        [self setUpStreamForFile:filePath];
    }
    return self;
}

- (void)start {
//    [_inputStream open];
    
}

- (void)cancel {
//    [_inputStream close];
}

- (void)setUpStreamForFile:(NSString *)path {
    // iStream is NSInputStream instance variable
}


#pragma mark -
#pragma mark NSStreamDelegate
//- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
//    NSLog(@"eventCode : %d",eventCode);
//    
//    uint8_t *buffer;
//    NSUInteger length = 0;
//    [_inputStream getBuffer:&buffer length:&length];
//    NSLog(@"%u %s",length,buffer);
//    
//}

- (void)decodeInFilePath:(NSString *)infilePath outFilePath:(NSString *)outfilePath {
#if 1
    const char *inFile = [infilePath UTF8String];
    const char *outFile = [outfilePath UTF8String];
    
    FILE *fin, *fout=NULL;
    short out[MAX_FRAME_SIZE];
    short output[MAX_FRAME_SIZE];
    int frame_size=0, granule_frame_size=0;
    void *st=NULL;
    SpeexBits bits;
    int packet_count=0;
    int stream_init = 0;
    int quiet = 0;
    ogg_int64_t page_granule=0, last_granule=0;
    int skip_samples=0, page_nb_packets;
    ogg_sync_state oy;
    ogg_page       og;
    ogg_packet     op;
    ogg_stream_state os;
    int enh_enabled;
    int nframes=2;
    int print_bitrate=0;
    int close_in=0;
    int eos=0;
    int forceMode=-1;
    int audio_size=0;
    float loss_percent=-1;
    SpeexStereoState stereo = SPEEX_STEREO_STATE_INIT;
    int channels=-1;
    int rate=0;
    int extra_headers=0;
    int wav_format=0;
    int lookahead;
    int speex_serialno = -1;
    
    enh_enabled = 1;  
    wav_format = strlen(outFile)>=4 && (
                                        strcmp(outFile+strlen(outFile)-4,".wav")==0
                                        || strcmp(outFile+strlen(outFile)-4,".WAV")==0);
    /*Open input file*/
    if (strcmp(inFile, "-")==0)
    {
#if defined WIN32 || defined _WIN32
        _setmode(_fileno(stdin), _O_BINARY);
#endif
        fin=stdin;
    }
    else 
    {
        fin = fopen(inFile, "rb");
        if (!fin)
        {
            perror(inFile);
            exit(1);
        }
        close_in=1;
    }
    
    
    /*Init Ogg data struct*/
    ogg_sync_init(&oy);
    
    speex_bits_init(&bits);
    /*Main decoding loop*/
    
    while (1)
    {
        char *data;
        int i, j, nb_read;
        /*Get the ogg buffer for writing*/
        data = ogg_sync_buffer(&oy, 200);
        /*Read bitstream from input file*/
        nb_read = fread(data, sizeof(char), 200, fin);      
        ogg_sync_wrote(&oy, nb_read);
        
        /*Loop for all complete pages we got (most likely only one)*/
        while (ogg_sync_pageout(&oy, &og)==1)
        {
            int packet_no;
            if (stream_init == 0) {
                ogg_stream_init(&os, ogg_page_serialno(&og));
                stream_init = 1;
            }
            if (ogg_page_serialno(&og) != os.serialno) {
                /* so all streams are read. */
                ogg_stream_reset_serialno(&os, ogg_page_serialno(&og));
            }
            /*Add page to the bitstream*/
            ogg_stream_pagein(&os, &og);
            page_granule = ogg_page_granulepos(&og);
            page_nb_packets = ogg_page_packets(&og);
            if (page_granule>0 && frame_size)
            {
                /* FIXME: shift the granule values if --force-* is specified */
                skip_samples = frame_size*(page_nb_packets*granule_frame_size*nframes - (page_granule-last_granule))/granule_frame_size;
                if (ogg_page_eos(&og))
                    skip_samples = -skip_samples;
                /*else if (!ogg_page_bos(&og))
                 skip_samples = 0;*/
            } else
            {
                skip_samples = 0;
            }
            /*printf ("page granulepos: %d %d %d\n", skip_samples, page_nb_packets, (int)page_granule);*/
            last_granule = page_granule;
            /*Extract all available packets*/
            packet_no=0;
            while (!eos && ogg_stream_packetout(&os, &op) == 1)
            {
                if (op.bytes>=5 && !memcmp(op.packet, "Speex", 5)) {
                    speex_serialno = os.serialno;
                }
                if (speex_serialno == -1 || os.serialno != speex_serialno)
                    break;
                /*If first packet, process as Speex header*/
                if (packet_count==0)
                {
                    st = process_header(&op, enh_enabled, &frame_size, &granule_frame_size, &rate, &nframes, forceMode, &channels, &stereo, &extra_headers, quiet);
/*
                    st=[self process_header:&op
                                enh_enabled:enh_enabled
                                 frame_size:&frame_size
                         granule_frame_size:&granule_frame_size
                                       rate:&rate
                                    nframes: &nframes
                                  forceMode:forceMode
                                   channels:&channels
                                     stereo:&stereo
                              extra_headers:&extra_headers
                                      quiet:quiet];
  */
                    if (!st)
                        exit(1);
                    speex_decoder_ctl(st, SPEEX_GET_LOOKAHEAD, &lookahead);
                    if (!nframes)
                        nframes=1;
                    fout = out_file_open(outFile, rate, &channels);
                    
                } else if (packet_count==1)
                {
                    if (!quiet) {
                        /*[self print_comments:(char*)op.packet length:op.bytes];*/                        
                    }
                } else if (packet_count<=1+extra_headers)
                {
                    /* Ignore extra headers */
                } else {
                    int lost=0;
                    packet_no++;
                    if (loss_percent>0 && 100*((float)rand())/RAND_MAX<loss_percent)
                        lost=1;
                    
                    /*End of stream condition*/
                    if (op.e_o_s && os.serialno == speex_serialno) /* don't care for anything except speex eos */
                        eos=1;
                    
                    /*Copy Ogg packet to Speex bitstream*/
                    speex_bits_read_from(&bits, (char*)op.packet, op.bytes);
                    for (j=0;j!=nframes;j++)
                    {
                        int ret;
                        /*Decode frame*/
                        if (!lost)
                            ret = speex_decode_int(st, &bits, output);
                        else
                            ret = speex_decode_int(st, NULL, output);
                        
                        /*for (i=0;i<frame_size*channels;i++)
                         printf ("%d\n", (int)output[i]);*/
                        
                        if (ret==-1)
                            break;
                        if (ret==-2)
                        {
                            fprintf (stderr, "Decoding error: corrupted stream?\n");
                            break;
                        }
                        if (speex_bits_remaining(&bits)<0)
                        {
                            fprintf (stderr, "Decoding overflow: corrupted stream?\n");
                            break;
                        }
                        if (channels==2)
                            speex_decode_stereo_int(output, frame_size, &stereo);
                        
                        if (print_bitrate) {
                            spx_int32_t tmp;
                            char ch=13;
                            speex_decoder_ctl(st, SPEEX_GET_BITRATE, &tmp);
                            fputc (ch, stderr);
                            fprintf (stderr, "Bitrate is use: %d bps     ", tmp);
                        }
                        /*Convert to short and save to output file*/
                        if (strlen(outFile)!=0)
                        {
                            for (i=0;i<frame_size*channels;i++)
                                out[i]=le_short(output[i]);
                        } else {
                            for (i=0;i<frame_size*channels;i++)
                                out[i]=output[i];
                        }
                        {
                            int frame_offset = 0;
                            int new_frame_size = frame_size;
                            /*printf ("packet %d %d\n", packet_no, skip_samples);*/
                            /*fprintf (stderr, "packet %d %d %d\n", packet_no, skip_samples, lookahead);*/
                            if (packet_no == 1 && j==0 && skip_samples > 0)
                            {
                                /*printf ("chopping first packet\n");*/
                                new_frame_size -= skip_samples+lookahead;
                                frame_offset = skip_samples+lookahead;
                            }
                            if (packet_no == page_nb_packets && skip_samples < 0)
                            {
                                int packet_length = nframes*frame_size+skip_samples+lookahead;
                                new_frame_size = packet_length - j*frame_size;
                                if (new_frame_size<0)
                                    new_frame_size = 0;
                                if (new_frame_size>frame_size)
                                    new_frame_size = frame_size;
                                /*printf ("chopping end: %d %d %d\n", new_frame_size, packet_length, packet_no);*/
                            }
                            if (new_frame_size>0)
                            {  
#if defined WIN32 || defined _WIN32
                                if (strlen(outFile)==0)
                                    WIN_Play_Samples (out+frame_offset*channels, sizeof(short) * new_frame_size*channels);
                                else
#endif
                                    fwrite(out+frame_offset*channels, sizeof(short), new_frame_size*channels, fout);
                                
                                audio_size+=sizeof(short)*new_frame_size*channels;
                            }
                        }
                    }
                }
                packet_count++;
            }
        }
        if (feof(fin))
            break;
        
    }
    
    if (fout && wav_format)
    {
        if (fseek(fout,4,SEEK_SET)==0)
        {
            int tmp;
            tmp = le_int(audio_size+36);
            fwrite(&tmp,4,1,fout);
            if (fseek(fout,32,SEEK_CUR)==0)
            {
                tmp = le_int(audio_size);
                fwrite(&tmp,4,1,fout);
            } else
            {
                fprintf (stderr, "First seek worked, second didn't\n");
            }
        } else {
            fprintf (stderr, "Cannot seek on wave file, size will be incorrect\n");
        }
    }
    
    if (st)
        speex_decoder_destroy(st);
    else 
    {
        fprintf (stderr, "This doesn't look like a Speex file\n");
    }
    speex_bits_destroy(&bits);
    if (stream_init)
        ogg_stream_clear(&os);
    ogg_sync_clear(&oy);
    
#if defined WIN32 || defined _WIN32
    if (strlen(outFile)==0)
        WIN_Audio_close ();
#endif
    
    if (close_in)
        fclose(fin);
    if (fout != NULL)
        fclose(fout);   
#endif  
}

#if 0
- (void)decodeInFilePath:(NSString *)infilePath outFilePath:(NSString *)outfilePath {
    if (infilePath == nil || infilePath.length == 0) {
        return;
    }
    
    char *inFile;
    
    char *outFile;
    FILE *fout;
    FILE *fin;
    /*Holds the audio that will be written to file (16 bits per sample)*/
    short out[FRAME_SIZE];
    /*Speex handle samples as float, so we need an array of floats*/
    float output[FRAME_SIZE];
    char cbits[200];
    int nbBytes;
    /*Holds the state of the decoder*/
    void *state;
    /*Holds bits so they can be read and written to by the Speex routines*/
    SpeexBits bits;
    int i, tmp;
    
    /*Create a new decoder state in narrowband mode*/
    state = speex_decoder_init(&speex_nb_mode);
    
    /*Set the perceptual enhancement on*/
    tmp=1;
    speex_decoder_ctl(state, SPEEX_SET_ENH, &tmp);
    
    inFile = (char*)[infilePath cStringUsingEncoding:NSUTF8StringEncoding];
    outFile = (char*)[outfilePath cStringUsingEncoding:NSUTF8StringEncoding];
    fin = fopen(inFile, "r");
    fout = fopen(outFile, "w");
    NSLog(@"inFile : %@",infilePath);
    NSLog(@"outFile : %@",outfilePath);
    
    /*Initialization of the structure that holds the bits*/
    speex_bits_init(&bits);
    while (1)
    {
        /*Read the size encoded by sampleenc, this part will likely be 
         different in your application*/
        fread(&nbBytes, sizeof(int), 1, fin);
        fprintf (stderr, "nbBytes: %d\n", nbBytes);
        if (feof(fin))
            break;
        
        /*Read the "packet" encoded by sampleenc*/
        fread(cbits, 1, nbBytes, stdin);
        /*Copy the data into the bit-stream struct*/
        speex_bits_read_from(&bits, cbits, nbBytes);
        
        /*Decode the data*/
        speex_decode(state, &bits, output);
        
        /*Copy from float to short (16 bits) for output*/
        for (i=0;i<FRAME_SIZE;i++)
            out[i]=output[i];
        
        /*Write the decoded audio to file*/
        fwrite(out, sizeof(short), FRAME_SIZE, fout);
    }
    
    /*Destroy the decoder state*/
    speex_decoder_destroy(state);
    /*Destroy the bit-stream truct*/
    speex_bits_destroy(&bits);
    fclose(fout);
//    return 0;

}

#endif
//+ (NSString *)description {
//    NSString *superDesc = [super description];
//    return [NSString stringWithFormat:@"%@-%@",superDesc,@"SpeexDecoder"];
//}
//

- (void)dealloc {
    [_inputStream close];
    [_inputStream release];
    [super dealloc];
}

@end
