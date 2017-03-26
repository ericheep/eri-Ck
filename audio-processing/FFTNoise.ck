// Eric Heep
// March 25th 2017
// FFTNoise.ck

// CAUTION: VERY LOUD

// Good for turning your voice into a smoke monster.
// Use with headphones, but watch out for the volume.

public class FFTNoise extends Chubgraph {

    // analyzation chain
    inlet => FFT fft => blackhole;
    fft =^ RMS rms;

    // fft settings
    256 => fft.size => int FFT_SIZE => int hop;
    Noise noise => HPF hp => LPF lp => outlet;
    Windowing.hamming(FFT_SIZE) => fft.window;

    // frequency of sampling
    second/samp => float FS;

    // setting filters
    lp.Q(0.5);
    lp.freq(FS/2.0);

    hp.Q(0.5);
    hp.freq(0);

    // turns on the noise
    fun void listen(int l) {
        if (l == 1) {
            1 => m_listen;
            spork ~ listening();
        }
        if (l == 0) {
            0 => m_listen;
        }
    }

    // analyze and produce noise
    fun void listening() {
        // arrays for our spectral calculations
        // (we define them here, because inside a funciton is a HUGE memory leak)
        float fftFrqs[(FFT_SIZE/2) + 1];
        float power[FFT_SIZE];
        float square[FFT_SIZE];

        float spreadVal, centroidVal;
        float lowPass, highPass, dbVal;

        while (lstnOn == 1) {
            hop::samp => now;

            centroid(fft.upchuck().fvals(), fftFrqs, power, FS, FFT_SIZE) => centroidVal;
            spread(fft.upchuck().fvals(), fftFrqs, power, square, centroidVal, FS, N) => spreadVal;
            rms.upchuck().fval(0) * 250 => dbVal;

            Math.fabs(centroidVal + (spreadVal/2.0)) => lowPass;
            Math.fabs(centroidVal - (spreadVal/2.0)) => highPass;

            if (dbVal > 0 || dbVal < 1.0) {
                noise.gain(dbVal);
            }
            if (lowPass > 0 && lowPass < 8000) {
                lp.freq(lowPass);
            }
            if (highPass > 0 && highPass < 8000) {
                hp.freq(highPass);
            }
        }
    }

    // spectral centroid
    fun float centroid(float X[], float fftFrqs[], float power[], float sr, int fftSize) {
        // center bin frequencies
        for (int i; i < fftFrqs.cap(); i++) {
            sr/fftSize * i => fftFrqs[i];
        }

        float den;
        for (int i; i < X.cap(); i++) {
            X[i] * X[i] => power[i];
            power[i] +=> den;
        }

        float num;
        for (int i; i < X.cap(); i++) {
            fftFrqs[i] * power[i] +=> num;
        }

        return num/den;
    }

    // spectral spread
    fun float spread(float X[], float fftFrqs[], float power[], float square[], float centroid, float sr, int fftSize) {
        // center bin frequencies
        for (int i; i < fftFrqs.cap(); i++) {
            sr/fftSize * i => fftFrqs[i];
        }

        float num, den;

        for(int i; i < X.cap(); i++) {
            X[i] * X[i] => power[i];
            Math.pow(fftFrqs[i] - centroid, 2) => square[i];
            power[i] * square[i] +=> num;
            power[i] +=> den;
        }
        return Math.sqrt(num/den);
    }
}

/*
adc => FFTNoise fft => dac;
fft.listen(1);

while (true) {
    1::second => now;
}
*/
