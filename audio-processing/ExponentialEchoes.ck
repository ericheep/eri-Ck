// ExponentialEchoes.ck
// March 25th, 2017
// Eric Heep

// These length of the echoes are created using the
// total duration of the effect and the amount of
// desired echoes that will occur within that duration.

// This method of calculation enables you to sync the
// ending of the growth/decay chain with the beginning
// of an event, or measure.

public class ExponentialEchoes extends Chubgraph {

    Echo ech[0];

    2::second => dur m_duration;
    8 => int m_numEchoes;
    0.5 => float m_feedback;
    1.0 => float m_mix;

    // set type
    true => int m_decay;
    false => int m_growth;

    numEchoes(m_numEchoes);
    duration(m_duration);

    fun void setDecay() {
        true => m_decay;
        false => m_growth;
        setEchoes(m_numEchoes, m_duration);
    }

    fun void setGrowth() {
        false => m_decay;
        true => m_growth;
        setEchoes(m_numEchoes, m_duration);
    }

    fun void numEchoes(int n) {
        n => m_numEchoes;

        if (ech.size() > 0) {
            unchainEchoes();
        }

        Echo e[n] @=> ech;

        chainEchoes();
        setEchoes(n, m_duration);
    }

    fun void chainEchoes() {
        inlet => ech[0];
        for (0 => int i; i < ech.size() - 1; i++) {
            ech[i] => ech[i + 1];
            ech[i] => outlet;
        }
        ech[ech.size() - 1] => outlet;
    }

    fun void unchainEchoes() {
        inlet =< ech[0];
        for (int i; i < ech.size() - 1; i++) {
            ech[i] =< ech[i + 1];
            ech[i] =< outlet;
        }
        ech[ech.cap() - 1] =< outlet;
    }

    fun void duration(dur d) {
        d => m_duration;
        if (ech.size() > 0) {
            setEchoes(ech.size(), m_duration);
        }
    }

    fun void setEchoes(int n, dur d) {
        1.0/n=> float inverseN;
        d * inverseN=> dur beatTime;

        0::samp => dur y;
        0::samp => dur echoLength;

        // calculates duration of each echo
        for (1 => int i; i < n + 1; i++) {
            Math.pow(Math.pow((1 + n),(inverseN)),(i)) - 1 => float beat;
            beat * beatTime => dur x;

            x - y => echoLength;
            beat * beatTime => y;

            // sets max delay time as well as delay time
            if (m_decay) {
                echoLength => ech[n - i].max => ech[n - i].delay;
            } else if (m_growth) {
                echoLength => ech[i - 1].max => ech[i - 1].delay;
            }
        }

        feedback(m_feedback);
        mix(m_mix);
    }

    // acts like a normal feedback delay parameter,
    // reducing the signal per echo
    fun void feedback(float f) {
        for (int i; i < ech.size(); i++) {
            f => ech[i].gain;
        }
        f => m_feedback;
    }

    // this allows a portion of the signal to go
    // directly through without delay to the next echo,
    // making it fairly experimental, great for adding recursive
    // mini-echoes inside of an echo, use with caution.
    // 1.0 for normal echoes, 0.5 for recursive
    fun void mix(float m) {
        for (int i; i < ech.size(); i++) {
            m => ech[i].mix;
        }
        m => m_mix;
    }
}

/*
adc => ExponentialEchoes exp => dac;

exp.numEchoes(16);

exp.duration(4::second);
exp.feedback(0.50);
exp.mix(1.00);

while (true) {
    1::second => now;
}
*/
