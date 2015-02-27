// red-beast

// Eric Heep
// for Manuel Lima's 2nd Year DMA Recital "Red Light Piano"
// MTIID4LIFE

public class MultiSin extends Chubgraph {

    float sin_frq[0];
    float sin_gain[0];
    float sin_prev_frq[0];

    float phase[0];
    float phase_inc[0];

    2 * pi => float two_pi;
    int num_cols;

    fun void init(int n) {
        // sin wave parameters
        n => sin_frq.size;
        n => sin_gain.size;
        n => sin_prev_frq.size;

        n => phase.size;
        n => phase_inc.size;

        n => num_cols;
    }

    fun void freq(int idx, float f) {
        f => sin_frq[idx];
    }

    fun void vol(int idx, float g) {
        g => sin_gain[idx];
    }

    // multiple sin stuff
    fun float[][] calc(float val[][]) {
        for (int i; i < num_cols; i++) {
            // moves valay around to next spot
            for (val[i].size() - 2 => int j; j >= 0; j--) {
                val[i][j] => val[i][j + 1];
            }
            
            // only calculates when needed
            if (sin_frq[i] != sin_prev_frq[i]) {
                sin_frq[i]/30.0 * two_pi => phase_inc[i];
                sin_frq[i] => sin_prev_frq[i];
            }

            // adds incrment to phase and wraps
            phase_inc[i] +=> phase[i];
            if (phase[i] > two_pi) {
                two_pi -=> phase[i];
            }
            
            // maps data into 0.0 to 1.0 values
            (Math.sin(phase[i]) + 1) * 0.5 * sin_gain[i] => val[i][0];
        }

        return val;
    }
}
