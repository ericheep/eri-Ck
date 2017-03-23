// Eric Heep
// March 19th, 2017
// AsymptopicChopper.ck

// Listens for a duration, then plays back a random
// half of that buffer, and then plays back a random
// half of that buffer, and continues to do so until the
// playback length of that diminishing buffer
// falls below a set minimum threshold. A fairly subtle chop.

public class AsymptopicChopper extends Chubgraph {

    inlet => LiSa mic => outlet;

    0 => int m_listen;
    3::second => dur m_bufferLength;
    10::second => dur m_maxBufferLength;
    100::ms => dur m_minimumLength;
    m_minimumLength * 0.5 => dur m_envLength;

    fun void listen(int lstn) {
        if (lstn == 1) {
            1 => m_listen;
            spork ~ listening();
        }
        if (lstn == 0) {
            0 => m_listen;
        }
    }

    fun void length(dur l) {
        l => m_bufferLength;
    }

    fun void maxLength(dur l) {
        l => m_maxBufferLength;
    }

    fun void minimumLength(dur l) {
        m_minimumLength;
        l * 0.5 => m_envLength;
    }

    fun void listening() {
        mic.duration(m_maxBufferLength);
        while (m_listen) {
            mic.clear();
            mic.recPos(0::samp);
            mic.record(1);
            m_bufferLength => now;
            mic.record(0);
            asymptopChop(m_bufferLength);
        }
    }

    fun void asymptopChop(dur bufferLength) {
        dur bufferStart;
        m_bufferLength => dur bufferLength;
        mic.play(1);
        while (bufferLength > m_minimumLength) {
            Math.random2(0, 1) => int which;
            bufferLength * 0.5 => bufferLength;
            bufferLength * which => bufferStart;
            mic.playPos(bufferStart);
            mic.rampUp(m_envLength);
            bufferLength - m_envLength => now;
            mic.rampDown(m_envLength);
            m_envLength => now;
        }
        mic.play(0);
    }
}

/*
adc => AsymptopicChopper a => dac;

a.listen(1);
a.length(3::second);
a.minimumLength(10::ms);
dac.gain(0.1);

while (true) {
    second => now;
}
*/
