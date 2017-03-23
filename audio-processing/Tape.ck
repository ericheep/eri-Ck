// Eric Heep
// March 23rd, 2017
// Tape.ck

// A simple tape looper using a delay line.
// Not much to it really.

public class Tape extends Chubgraph {
    inlet => Delay del => ADSR env => Gain g => outlet;
    g => del;

    env.set(50::ms, 0::ms, 1.0, 50::ms);
    delayLength(1::second);

    0 => int m_loop;

    fun void delayLength(dur d) {
        del.max(d);
        del.delay(d);
    }

    fun void loop(int l) {
        if (l) {
            1 => m_loop;
            spork ~ looping();
        }
        if (l == 0) {
            0 => m_loop;
        }
    }

    fun void looping() {
        env.keyOn();
        while (m_loop) {
            1::samp => now;
        }
        env.keyOff();
    }
}

/*
adc => Tape t => dac;
t.gain(0.1);
t.delayLength(1::second);
t.loop(1);

while (true) {
    second => now;
}
*/
