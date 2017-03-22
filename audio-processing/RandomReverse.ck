// Eric Heep
// March 14th, 2017
// RandomReverse.ck

public class RandomReverse extends Chubgraph {

    inlet => LiSa mic => Gain r => outlet;
    inlet => Gain g => ADSR env => outlet;

    0 => int m_listen;
    2::second => dur m_maxBufferLength;
    2::second => dur m_bufferLength;
    0.5 => float m_influence;
    100::ms => dur m_envDuration;
    5::second => dur m_maxTimeBetween;

    // envelope
    env.attackTime(m_envDuration);
    env.releaseTime(m_envDuration);
    env.keyOn();

    fun void listen(int l) {
        if (l == 1) {
            1 => m_listen;
            spork ~ listening();
        }
        if (l == 0) {
            0 => m_listen;
        }
    }

    fun void setInfluence(float i) {
        i => m_influence;
    }

    fun void setReverseGain(float g) {
        r.gain(g);
    }

    fun void setMaxBufferLength(dur l) {
        l => m_maxBufferLength;
    }

    fun void listening() {
        mic.duration(m_maxBufferLength);
        while (m_listen) {
            if (m_influence >= 0.01) {
                Math.random2f(0.1, m_influence * 0.75) => float scale;
                scale * m_bufferLength => dur bufferLength;
                record(bufferLength);
                playInReverse(bufferLength);
                m_maxTimeBetween * Math.fabs(1.0 - m_influence) => now;
            }
            1::samp => now;
        }
    }

    fun void record(dur bufferLength) {
        mic.playPos(0::samp);
        mic.record(1);
        bufferLength => now;
        mic.record(0);
    }

    fun void playInReverse(dur bufferLength) {
        if (bufferLength < m_envDuration) {
            m_envDuration * 2 => bufferLength;
        }
        env.keyOff();
        mic.play(1);
        mic.playPos(bufferLength);
        mic.rate(-1.0);
        mic.rampUp(m_envDuration);
        bufferLength - m_envDuration => now;
        mic.rampDown(m_envDuration);
        env.keyOn();
        m_envDuration => now;
        mic.play(0);
    }


}

/*
RandomReverse rr;
adc => rr => dac;

rr.setInfluence(1.0);
rr.listen(1);

while (true ) {
    1::second => now;
}
*/
