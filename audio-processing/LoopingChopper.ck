// Eric Heep
// March 18th, 2017
// LoopingChopper.ck

public class LoopingChopper extends Chubgraph {

    LiSa mic[2];
    inlet => mic[0] => outlet;
    inlet => mic[1] => outlet;

    4 => int m_numChops;
    4 => int m_minChops;
    24 => int m_maxChops;

    m_maxChops - m_minChops => int m_chopRange;
    0 => int m_listen;
    1::second => dur m_bufferLength;

    fun void setMinChops(int min) {
        min => m_minChops;
        m_maxChops - m_minChops => m_chopRange;

    }

    fun void setMaxChops(int max) {
        max => m_maxChops;
        m_maxChops - m_minChops => m_chopRange;
    }

    fun void density(float d) {
        (d * m_chopRange)$int + m_minChops => m_numChops;
    }

    fun void listen(int lstn) {
        if (lstn == 1) {
            1 => m_listen;
            spork ~ recording();
        }
        if (lstn == 0) {
            0 => m_listen;
        }
    }

    fun void recording() {
        0 => int idx;
        mic[0].duration(m_bufferLength);
        mic[1].duration(m_bufferLength);

        while (m_listen) {
            m_bufferLength => dur bufferLength;
            mic[idx].clear();
            mic[idx].recPos(0::samp);
            mic[idx].record(1);
            bufferLength => now;
            mic[idx].record(0);
            spork ~ chopper(mic[idx], bufferLength);
            (idx + 1) % 2 => idx;
        }
    }

    fun void chopper(LiSa mic, dur bufferLength) {
        mic.play(1);
        m_numChops => int numChops;
        bufferLength/(numChops$float) => dur chopLength;
        for (0 => int i; i < numChops; i++) {
            Math.random2(0, numChops - 1) * chopLength => dur playPos;
            mic.rampUp(20::ms);
            mic.playPos(playPos);
            chopLength - 20::ms => now;
            mic.rampDown(20::ms);
            20::ms => now;
        }
        mic.play(0);
    }


}

/*
4 => int NUM;
LoopingChopper l[NUM];

for (0 => int i; i < NUM; i++) {
    adc => l[i] => dac;
    l[i].listen(1);
}


while (true) {
    for (0 => int i; i < NUM; i++) {
        l[i].density(Math.random2f(0.4, 1.0));
    }
    second => now;
}
*/
