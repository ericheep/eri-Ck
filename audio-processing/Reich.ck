// Eric Heep
// March 28th, 2017
// Reich.ck

// A looper that imploys a Reich-like phasing method
// to duplicate a single recording and create a pad-like
// atmosphere.

public class Reich extends Chubgraph {

    inlet => LiSa mic => outlet;

    0 => int m_record;
    0 => int m_play;

    0::ms => dur m_length;
    4     => int m_voices;
    1.001 => float m_speed;

    false => int m_bi;
    false => int m_random;
    false => int m_spread;

    maxBufferLength(8::second);

    fun void maxBufferLength(dur l) {
        mic.duration(l);
    }

    fun void record(int r) {
        if (r == 1) {
            1 => m_record;
            spork ~ recording();
        }
        if (r == 0) {
            0 => m_record;
        }
    }

    fun void recording() {
        mic.clear();

        mic.recPos(0::samp);
        mic.record(1);

        while (m_record == 1) {
            1::samp => now;
        }

        mic.record(0);
        mic.recPos() => m_length;
    }

    fun void play(int p) {
        if (p == 1) {
            1 => m_play;
            spork ~ playing();
        }
        if (p == 0) {
            0 => m_play;
        }

    }

    fun void playing() {
        m_voices => int numVoices;
        for (int i; i < numVoices; i++) {
            0::ms => dur pos;
            if (m_random) {
                Math.random2f(0.5,1.0) * m_length => pos;
            } else if (m_spread) {
                i/(numVoices$float) * m_length => pos;
            }
            mic.playPos(i, pos);

            // set parameters
            mic.bi(i, m_bi);
            mic.rate(i, (m_speed - 1.0) * i + 1);
            mic.loop(i, 1);
            mic.loopEnd(i, m_length);

            mic.play(i, 1);
        }
        while (m_play == 1) {
            samp => now;
        }
        for (int i; i < numVoices; i++) {
            mic.play(i, 0);
        }
    }

    // spreads the initial voices randomly
    // throughout the record buffer
    fun void random(int r) {
        r => m_random;
    }

    // spreads the initial voices equally
    // throughout the record buffer
    fun void spread(int r) {
        r => m_spread;
    }

    // plays a voice backwards when reaching
    // the end of the buffer, otherwise
    // it will loop from the beginning
    fun void bi(int b) {
        b => m_bi;
    }

    // the number of voices to be played back
    fun void voices(int n) {
        n => m_voices;
    }

    // speed offset for the voices
    fun void speed(float s) {
        s => m_speed;
    }
}

/*
adc => Reich r => dac;

r.record(1);
2::second => now;
r.record(0);

r.play(1);

while (true) {
    samp => now;
}
*/



