// Decay.ck
// March 13th, 2017
// Eric Heep

public class Decay extends Chubgraph {

    Echo ech[0];

    dur m_len;

    int m_numDecays;
    float m_mix;
    float m_feedback;

    fun void decays(int numDecays) {
        numDecays => m_numDecays;
        if (ech.size() > 0) {
            unchainDecays();
        }

        Echo e[numDecays] @=> ech;

        chainDecays();
        inlet => outlet;
    }

    fun void decayGain(float f) {
        for (int i; i < ech.size() - 1; i++) {
            ech[i].gain(f);
        }
    }

    fun void chainDecays() {
        inlet => ech[0];
        for (int i; i < ech.size() - 1; i++) {
            ech[i] => ech[i + 1];
            ech[i] => outlet;
        }
        ech[ech.size() - 1] => outlet;
    }

    fun void unchainDecays() {
        inlet =< ech[0];
        for (int i; i < ech.size() - 1; i++) {
            ech[i] =< ech[i + 1];
        }
        ech[ech.cap() - 1] =< outlet;
    }

    fun void length(dur len) {
        if (len == m_len) {
            return;
        }

        len => m_len;

        ech.size()$float => float div;
        len/div => dur beatTime;

        0::samp => dur y;

        // calculates length of each echo
        for (1 => int i; i < ech.size()+ 1; i++ ) {
            Math.pow(Math.pow((1 + div),(1/div)),(i)) - 1 => float beat;
            beat * beatTime => dur x;

            x - y => dur difference;
            beat * beatTime => y;

            // sets max delay time as well as delay time
            difference => ech[ech.size() - i].max => ech[ech.size() - i].delay;
        }
    }

    fun void feedback(float f) {
        for (int i; i < ech.size(); i++) {
            f => ech[i].gain;
        }
    }

    fun void mix(float m) {
        for (int i; i < ech.size(); i++) {
            m => ech[i].mix;
        }
    }
}

/*
adc => Decay exp => dac;
adc => Gain g => dac;

exp.decays(16);
exp.length(16::second);
exp.feedback(0.50);
exp.mix(1.0);

while (true) {
    1::second => now;
}
*/
