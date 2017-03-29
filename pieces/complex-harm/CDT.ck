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

    1.24 => float m_ratio;
    440 => float m_CDTFreq;

    0.0 => float m_f1Freq;
    0.0 => float m_f2Freq;

    setCDT(m_CDTFreq, m_ratio);

    // sets gain of f1
    fun void f1Gain(float g) {
        f1.gain(g); }

    // sets gain of f2
    fun void f2Gain(float g) {
        f2.gain(g);
    }

    // get f1 freq
    fun float f1Freq() {
        return m_f1Freq;
    }

    // get f2 freq
    fun float f2Freq() {
        return m_f2Freq;
    }

    // sets frequency of the CDT
    fun float freq(float f) {
        f => m_CDTFreq;
        setCDT(m_CDTFreq, m_ratio);
    }

    // gets frequency of the CDT
    fun float freq() {
        return m_CDTFreq;
    }

    // sets the ratio of the two frequencies
    // must be exclusively between 1.0 and 2.0
    fun float ratio(float r) {
        if (r > 1.0 && r < 2.0) {
            r => m_ratio;
            setCDT(m_CDTFreq, m_ratio);
        }
        else {
            <<< "Ratio falls outside of expected range (1.0, 2.0)", "" >>>;
        }
    }

    // gets the ratio of the two frequencies
    fun float ratio() {
        return m_ratio;
    }

    // internal function to set CDT after either
    // the ratio between f1 and f2 is changed,
    // or if the desired frequency of the CDT is changed
    fun void setCDT(float CDTFreq, float ratio) {
        CDTFreq/(2.0 - ratio) => m_f1Freq;
        2 * m_f1Freq - CDTFreq => m_f2Freq;
        if (m_f1Freq > 22050 || m_f2Freq > 22050) {
            <<< "Caution: A tone has fallen outside the audible range.", m_f1Freq, m_f2Freq, "" >>>;
        }

        f1.freq(m_f1Freq);
        f2.freq(m_f2Freq);
    }
}

// Quick example that changes the ratios of the
// CDT while keeping the same distortion tone frequency.

/*
CDT c => dac;
c.gain(0.4);
c.freq(440);

[1.18, 1.19, 1.20, 1.21, 1.22] @=> float ratios[];
int inc;

while (true) {
    c.ratio(ratios[inc]);
    5::second => now;
    (inc + 1) % ratios.size() => inc;
}
*/
