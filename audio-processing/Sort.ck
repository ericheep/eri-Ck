// Eric Heep
// March 25th, 2017
// SortGrains.ck

// Sorts grains of audio according to their amplitude values,
// loops the sorted grains as rising waves and falling waves,
// following their ascension or descension.

public class SortGrains extends Chubgraph {

    inlet => LiSa mic => outlet;

    50::ms => dur m_stepTime;
    10::ms => dur m_rampTime;

    0 => int m_record;
    0 => int m_play;

    1.0 => float m_max;
    0.0 => float m_min;

    0 => int m_inc;
    0 => int m_direction;
    0 => int m_hardMax;

    int m_arg[0];

    maxDuration(8::second);

    fun void rampTime(dur r) {
        r => m_rampTime;
    }

    fun void maxPos(float m) {
        m => m_max;
    }

    fun void minPos(float m) {
        m => m_min;
    }

    // step duration
    fun void stepDuration(dur s) {
        s => m_stepTime;
    }

    // max buffer size
    fun void maxDuration(dur d) {
        mic.duration(d);
    }

    // index sorting
    fun int[] argSort(float x[]) {
        int idx[x.cap()];
        for (int i; i < x.cap(); i++) {
           float max;
           int idx_max;
           for (int j; j < x.cap(); j++) {
                if (x[j] >= max) {
                    x[j] => max;
                    j => idx_max;
                }
            }
            idx_max => idx[i];
            0 => x[idx_max];
        }
        return idx;
    }

    fun int[] findMeans(dur s, dur l) {
        (l/s) $ int => int div;
        float means[div];

        s/div => dur chunk;

        // loop for finding the average values of the grains of audio
        for (int i; i < div; i++) {
            float sum;

            // loops through the samples, takes the
            // absolute value to find the average
            for (int j; j < div; j++) {
                Math.fabs(mic.valueAt((j + (i * div)) * chunk)) +=> sum;
            }

            sum/(s/ms) => means[i];
        }

        return argSort(means);
    }

    fun void play(int p) {
        if (p) {
            1 => m_play;
            spork ~ playing();
        }
        if (p == 0) {
            0 => m_play;
        }
    }

    fun void playing() {
        mic.play(1);
        m_arg.size() => int numGrains;
        (m_min * numGrains)$int => m_inc;

        while(m_play) {
            if (m_inc < 0) {
                0 => m_inc;
            } else if (m_inc >= numGrains) {
                numGrains - 1 => m_inc;
            }

            // play
            mic.playPos(m_stepTime * m_arg[m_inc]);
            mic.rampUp(m_rampTime);
            m_stepTime - m_rampTime => now;
            mic.rampDown(m_rampTime);
            m_rampTime => now;

            // direction logic, goes up or down
            m_direction +=> m_inc;

            if (m_inc >= numGrains - 1 || m_inc == ((1.0 - m_min)* numGrains)$int) {
                -1 => m_direction;
            }
            if (m_inc <= 0 || m_inc == ((1.0 - m_max) * numGrains)$int) {
                1 => m_direction;
            }
        }

        mic.play(0);
    }

    fun void record(int r) {
        if (r) {
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

        while (m_record) {
            1::samp => now;
        }

        mic.record(0);
        mic.recPos() => dur length;

        findMeans(m_stepTime, length) @=> m_arg;
    }
}

adc => SortGrains s => dac;

s.record(1);
2000::ms => now;
s.record(0);

s.minPos(0.99);
s.play(1);

while (true) {
    1::second => now;
}
