// BHEnv.ck

// Eric Heep
// Blackman-Harris Envelope Class 

public class BHEnv extends Chugen {
    // initial coefficients
    0.35875 => float a0;
    0.48829 => float a1;
    0.14128 => float a2;
    0.01168 => float a3;

    // arrays
    float w_up[0];
    float w_down[0];

    dur dur_up, dur_down;
    int env_up, env_down, inc_up, inc_down;

    // "ramps" up
    fun void up(dur e) {
        if (dur_up != e) {
            e => dur_up;
            calc(dur_up, 0);
        }
        1 => env_up;
        0 => inc_up;
    }

    // "ramps" down 
    fun void down(dur e) {
        if (dur_down != e) {
            e => dur_down;
            calc(dur_down, 1);
        }
        1 => env_down;
        0 => inc_down;
    }

    // can call beforehand for faster processing
    fun float[] calc(dur len, int which) {
        // finds number of samples per array
        (len/samp) $ int => int half_N;

        // window
        half_N * 2 => int N;

        // blackman harris calculation
        if (which == 0) {
            half_N => w_up.size;
            for (int i; i < half_N; i++) {
                a0 => float t0;
                a1 * Math.cos((2 * pi * i)/N) => float t1;
                a2 * Math.cos((4 * pi * i)/N) => float t2;
                a3 * Math.cos((6 * pi * i)/N) => float t3; 

                t0 - t1 + t2 - t3 => w_up[i];
            }
            len => dur_up;
        }
        if (which == 1) {
            half_N => w_down.size;
            for (half_N => int i; i < N; i++) {
                a0 => float t0;
                a1 * Math.cos((2 * pi * i)/N) => float t1;
                a2 * Math.cos((4 * pi * i)/N) => float t2;
                a3 * Math.cos((6 * pi * i)/N) => float t3; 

                t0 - t1 + t2 - t3 => w_down[i - half_N];
            }
            len => dur_down;
        }
    }
    
    // when a envelope is started, the appropriate windowed
    // array is multiplied by the input for the size of the array
    fun float tick (float in) {
        if (env_up) {
            if (inc_up < w_up.cap()) {
                w_up[inc_up] * in => in;        
                inc_up++;
            }
            else {
                0 => inc_up;
                0 => env_up;
            }
        }
        if (env_down) {
            if (inc_down < w_down.cap()) {
                w_down[inc_down] * in => in;        
                inc_down++;
            }
            else {
                0 => inc_down;
                0 => env_down;
            }
        }
        return in;
    }
}
