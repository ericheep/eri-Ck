// Eric Heep
// March 28th, 2017
// Listener.ck


public class Listener extends Chubgraph {

    inlet => PitchTrack pt => blackhole;
    inlet => Gain g => OnePole p => blackhole;
    inlet => g;

    3 => g.op;
    0.999 => p.pole;

    float m_freqReadings[0];
    float m_dbReadings[0];

    0   => int m_listen;
    10  => int m_dbSize;
    750 => int m_freqSize;

    5.0 => float m_dbThreshold;
    0.0 => float m_db;

    10::ms =>  dur readingDuration;

    dbFilterSize(m_dbSize);
    freqFilterSize(m_freqSize);

    fun void sensitivity(float s) {
        pt.sensitivity(s);
    }

    fun void fidelity(float f) {
        pt.fidelity(f);
    }

    fun void freqFilterSize(int s) {
        s => m_freqSize;
        m_freqReadings.size(s);
        for (0 => int i; i < s; i++) {
            Math.random2f(0.0, 1000.0) => m_freqReadings[i];
        }
    }

    fun void dbFilterSize(int s) {
        s => m_dbSize;
        m_dbReadings.size(s);
    }

    fun void listen(int l) {
        if (l == 1) {
            1 => m_listen;
            spork ~ listening();
        }
        if (l == 0) {
            0 => m_listen;
        }
    }

    fun void listening() {
        while (m_listen) {
            Std.rmstodb(p.last()) => m_db;
            for (int i; i < m_dbSize - 1; i++) {
                m_dbReadings[i + 1] => m_dbReadings[i];
            }
            m_db => m_dbReadings[m_dbSize - 1];

            if (dbMean() > m_dbThreshold) {
                pt.get() => m_freqReadings[m_freqSize - 1];

                for (int i; i < m_freqSize - 1; i++) {
                    m_freqReadings[i + 1] => m_freqReadings[i];
                }
            }

            readingDuration => now;
        }
    }

    fun float freq() {
        return pt.get();
    }

    fun float db() {
        return m_db;
    }

    fun float freqStd() {
        return std(m_freqReadings);
    }

    fun float freqMean() {
        return mean(m_freqReadings);
    }

    fun float dbStd() {
        return std(m_dbReadings);
    }

    fun float dbMean() {
        return mean(m_dbReadings);
    }

    fun float mean(float x[]) {
        0.0 => float sum;
        for (0 => int i; i < x.size(); i++) {
            x[i] +=> sum;
        }

        return sum/x.size();
    }

    fun float std(float x[]) {
        mean(x) => float m;

        0.0 => float sum;

        for (0 => int i; i < x.size(); i++) {
            Math.pow(x[i] - m, 2) +=> sum;
        }

        return Math.sqrt(sum/x.size());
    }
}

/*
adc => Listener l;

l.listen(1);
l.fidelity(0.5);
// l.sensitivity(0.1);

while (true) {
    <<< "Freq:", l.freqMean(), 1.0 - l.freqStd(),
        "Decibel:", l.dbMean(), l.dbStd() >>>;
    100::ms => now;
}
*/
