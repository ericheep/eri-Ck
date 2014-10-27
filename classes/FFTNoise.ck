public class FFTNoise extends Chubgraph {

    inlet => FFT fft =^ Centroid cent => blackhole;
    fft =^ RMS rms;
    256 => int N => int win => fft.size;
    Noise noise => LPF lp => outlet;
    lp.Q(1.0);
    lp.freq(0);

    Windowing.hamming(N) => fft.window;
    UAnaBlob blob;
    second/samp => float sr;
    sr/2.0 => float nyquist;

    int low, high, lstnOn;
    0.1 => float threshold; 


    fun void listen(int lstn) {
        if (lstn == 1) {
            spork ~ listening();
        }
        if (lstn == 0) {
            0 => lstnOn;
        }
    }

    fun void listening() {
        1 => lstnOn;
        while (lstnOn == 1) {
            rms.upchuck() @=> blob;
            cent.upchuck();
            win::samp => now;   
            noise.gain(blob.fval(0) * 10);
            lp.freq(cent.fval(0) * nyquist);
        }
    }

}
