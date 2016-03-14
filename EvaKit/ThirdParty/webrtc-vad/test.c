#include <webrtc/common_audio/vad/include/webrtc_vad.h>
#include <stdio.h>


int
main ()
{
    VadInst *handle;
    int NN = 160;
    short buf[NN];

    WebRtcVad_Create (&handle);
    WebRtcVad_Init(handle);

    while (1) {
	int vad;
	fread (buf, sizeof (short), NN, stdin);
	if (feof (stdin))
	    break;
	vad = WebRtcVad_Process (handle, 16000, buf, NN);
	printf ("%d\n", vad);
    }


    WebRtcVad_Free (handle);
}
