// Eric Heep
// March 25th, 2017
// Micro.ck

// Live sampling class centered around micro loops.
// Meant for quickly sampling small segments of audio.
// Very simple and effective class.

public class Micro extends Chubgraph{
    inlet => LiSa mic => outlet;

    0 => int m_loop;
    100::ms => dur m_length;
    50::ms => dur m_rampTime;
    maxLoopTime(8::second);

    fun void rampTime(dur r) {
        r => m_rampTime;
    }

    fun void maxLoopTime(dur l) {
        mic.duration(l);
    }

    fun void loopTime(dur l) {
        l => m_length;
    }

    fun void loop(int k) {
        if (k == 1) {
            1 => m_loop;
            spork ~ looping();
        }
        if (k == 0) {
            0 => m_loop;
        }
    }

    fun void looping () {
        mic.clear();
        mic.recPos(0::samp);
        mic.record(1);
        m_length => now;
        mic.record(0);
        mic.play(1);
        while (m_loop) {
            mic.playPos(0::samp);
            mic.rampUp(m_rampTime);
            m_length - m_rampTime => now;
            mic.rampDown(m_rampTime);
            m_rampTime => now;
        }
        mic.play(0);
    }
}

adc => Micro m => dac;

/*
while (true) {
    m.loop(1);
    1::second => now;
    m.loop(0);
    1::second => now;
}
*/
