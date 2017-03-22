// Eric Heep
// March 19th, 2017
// AsymptopicChopper.ck

public class AsymptopicChopper extends Chubgraph {

    inlet => LiSa mic => outlet;

    0 => int m_listen;
    3::second => dur m_bufferLength;
    10::second => dur m_maxBufferLength;

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

    fun void listening() {
        mic.duration(m_maxBufferLength);
        while (m_listen) {
            mic.recPos(0::samp);
            mic.record(1);
            m_bufferLength => now;
            mic.record(0);
            asymptopChop(m_bufferLength);
        }
    }

    fun void asymptopChop(dur bufferLength) {
        dur bufferStart;
        mic.play(1);
        while (m_bufferLength > 100::ms) {
            Math.random2(0, 1) => int which;
            m_bufferLength * 0.5 => m_bufferLength;
            m_bufferLength * which => bufferStart;
            mic.playPos(bufferStart);
            mic.rampUp(50::ms);
            m_bufferLength - 50::ms => now;
            mic.rampDown(50::ms);
            50::ms => now;
        }
        mic.play(0);
    }
}

/*
4 => int NUM;

AsymptopicChopper a[NUM];

for (0 => int i; i < NUM; i++) {
    adc => a[i] => dac;
    a[i].listen(1);
}

dac.gain(0.0);

while (true) {
    for (0 => int i; i < NUM; i++) {
        a[i].length(Math.random2f(0.9, 1.1) * second);
    }
    second => now;

}
*/
