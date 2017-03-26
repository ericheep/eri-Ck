// Eric Heep
// November 2016
// CTD.ck

// Cubic Distortion Tone class that given the
// the frequency for a desired distortion tone,
// will play the two sine waves to produce that
// otoacoustic emission. Based on the following papers.

// http://www.mitpressjournals.org/doi/pdf/10.1162/COMJ_a_00265
// "Sound Synthesis with Auditory Distortion Products"


// http://www.sonami.net/Articles/Amacher-OAE.pdf
// "Psychoacoustic Phenomena in Musical Composition:
// Some Features of a "Perceptual Geography"


// https://ccrma.stanford.edu/~chechile/eartonetoolbox/Chechile_ICMC16.pdf
// "The Ear Tone Toolbox for Auditory Distortion Product Synthesis"


public class CDT extends Chubgraph {

    SinOsc f1 => outlet;
    SinOsc f2 => outlet;

    // initialize
    1.24 => float CDTRatio;
    440 => float CDTFreq;
    setCDT();

    // sets gain of f1
    fun void f1Gain(float f) {
        f1.gain(f); }

    // sets gain of f2
    fun void f2Gain(float f) {
        f2.gain(f);
    }

    // sets frequency of the CDT
    fun float freq(float f) {
        f => CDTFreq;
        setCDT();
    }

    // gets frequency of the CDT
    fun float freq() {
        return CDTFreq;
    }

    // sets the ratio of the two frequencies
    // must be exclusively between 1.0 and 2.0
    fun float ratio(float r) {
        if (r > 1.0 && r < 2.0) {
            r => CDTRatio;
            setCDT();
        }
        else {
            <<< "Ratio falls outside of expected range (1.0, 2.0)", "" >>>;
        }
    }

    // gets the ratio of the two frequencies
    fun float ratio() {
        return CDTRatio;
    }

    // internal function to set CDT after either
    // the ratio between f1 and f2 is changed,
    // or if the desired frequency of the CDT is changed
    fun void setCDT() {
        CDTFreq/(2.0 - CDTRatio) => f1.freq;
        2 * f1.freq() - CDTFreq => f2.freq;
        if (f1.freq() > 22050 || f2.freq() > 22050) {
            <<< "Caution: A tone has fallen outside the audible range.", f1.freq(), f2.freq(), "" >>>;
        }
    }
}

// Quick example that changes the ratios of the
// CDT while keeping the same distortion tone frequency.

/*
CDT c => dac;

c.freq(440);
[1.18, 1.19, 1.20, 1.21, 1.22] @=> float ratios[];

int inc;

while (true) {
    (inc + 1) % ratios.size() => inc;
    c.ratio(ratios[inc]);
    <<< ratios[inc] >>>;
    5::second => now;
}
*/
