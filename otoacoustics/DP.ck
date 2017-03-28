// Eric Heep
// March 2017
// DP.ck

// Distortion product using both a the values of a
// Cubic Distortion Tone and a Quadratic Distoriton Tone
// to produce two sine waves that will generate bothe of the
// desired distortion products. Based on the following papers.

// http://www.mitpressjournals.org/doi/pdf/10.1162/COMJ_a_00265
// "Sound Synthesis with Auditory Distortion Products"


// http://www.sonami.net/Articles/Amacher-OAE.pdf
// "Psychoacoustic Phenomena in Musical Composition:
// Some Features of a "Perceptual Geography"


// https://ccrma.stanford.edu/~chechile/eartonetoolbox/Chechile_ICMC16.pdf
// "The Ear Tone Toolbox for Auditory Distortion Product Synthesis"


public class DP extends Chubgraph {

    SinOsc f1 => outlet;
    SinOsc f2 => outlet;

    // initialize
    1.24 => float CDTRatio;
    440 => float m_QTFreq;
    660 => float m_CDTFreq;

    0.0 => float m_f1Freq;
    0.0 => float m_f2Freq;

    setDP(m_QTFreq, m_CDTFreq);

    // sets gain of f1
    fun void f1Gain(float f) {
        f1.gain(f); }

    // sets gain of f2
    fun void f2Gain(float f) {
        f2.gain(f);
    }

    // sets frequency of the CDT
    fun float freq(float QTFreq, float CDTFreq) {
        QTFreq => m_QTFreq;
        CDTFreq => m_CDTFreq;
        setDP(m_QTFreq, m_CDTFreq);
    }

    // gets the ratio of the two frequencies
    fun float ratio() {
        return m_f2Freq/m_f1Freq;
    }

    // calculates and sets the values of the two tones
    // that will create the specified CDT and QT
    fun void setDP(float QTFreq, float CDTFreq) {
        QTFreq + CDTFreq => m_f1Freq;
        2.0 * QTFreq + CDTFreq => m_f2Freq;
        if (m_f1Freq > 22050 || m_f2Freq > 22050) {
            <<< "Caution: A tone has fallen outside the audible range.", m_f1Freq, m_f2Freq, "" >>>;
        }
        f1.freq(m_f1Freq);
        f2.freq(m_f2Freq);
    }
}


/*
// Quick example creates both distortion products
// given their desired frequencies.

DP d => dac;
SinOsc s1 => dac;
SinOsc s2 => dac;

600 => float QTFreq;
2600 => float CDTFreq;

s1.freq(QTFreq);
s2.freq(CDTFreq);

d.freq(QTFreq, CDTFreq);
<<< d.ratio(), "" >>>;

while (true) {
    s1.gain(0.0);
    s2.gain(0.0);
    d.gain(0.5);
    5::second => now;
    s1.gain(0.2);
    s2.gain(0.0);
    d.gain(0.0);
    0.5::second => now;
    s1.gain(0.0);
    s2.gain(0.2);
    d.gain(0.0);
    0.5::second => now;
}
*/
