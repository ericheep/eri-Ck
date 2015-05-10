// red-beast

// Eric Heep
// for Manuel Lima's 2nd Year DMA Recital "Red Light Piano"
// MTIID4LIFE

public class MultiSin extends Chubgraph {

    MagicSine sin[7];
    Gain hot[7];
    int act[7];

    for (int i; i < 7; i++) {
        sin[i] => hot[i] => dac.chan(i % 4);
        sin[i].gain(0.0);
        sin[i] => dac.chan(5);
        hot[i].gain(0.0);
    }


    float sin_adjust;
    float frq[0];
    float vl[0];
    float prev_frq[0];

    float phase[0];
    float phase_inc[0];

    2 * pi => float two_pi;
    int num_cols;

    fun void init(int n) {
        // sin wave parameters
        n => frq.size;
        n => vl.size;
        n => prev_frq.size;

        n => phase.size;
        n => phase_inc.size;

        n => num_cols;
    }

    fun void active(int idx, int a) {
        if (a == 0) {
            0 => act[idx];
            hot[idx].gain(0.0);
        }
        if (a == 1) {
            1 => act[idx];
            hot[idx].gain(1.0);
        }
    }

    fun void adjust(float a) {
        a => sin_adjust;
    }

    fun void freq(int idx, float f) {
        f => frq[idx];
        sin[idx].freq(f);
    }

    fun void vol(int idx, float g) {
        g * sin_adjust => vl[idx];
        sin[idx].gain(g);
    }

    // multiple sin stuff
    fun float[][] calc(float val[][]) {
        for (int i; i < 7; i++) {
            if (act[i]) {
                for (int i; i < num_cols; i++) {
                    // moves valay around to next spot
                    for (val[i].size() - 2 => int j; j >= 0; j--) {
                        val[i][j] => val[i][j + 1];
                    }
                    
                    // only calculates when needed
                    if (frq[i] != prev_frq[i]) {
                        frq[i]/30.0 * two_pi => phase_inc[i];
                        frq[i] => prev_frq[i];
                    }

                    // adds incrment to phase and wraps
                    phase_inc[i] +=> phase[i];
                    if (phase[i] > two_pi) {
                        two_pi -=> phase[i];
                    }
                    
                    // maps data into 0.0 to 1.0 values
                    (Math.sin(phase[i]) + 1) * 0.5 * vl[i] => val[i][0];
                }
            }
        }

        return val;
    }
}
