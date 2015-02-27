// ExpEnv.ck

// Eric Heep
// Exponential Envelope Class

public class ExpEnv extends Chugen {
 
    // arrays
    float w_up[0];
    float w_down[0];

    dur dur_up, dur_down;
    int env_up, env_down, inc_up, inc_down;

    float exp; 
    power(2.0);
    
    fun void power(float e) {
        e => exp;
    }
   
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
        (len/samp) $ int => int k;

        if (which == 0) {
            k => w_up.size;
            1.0/k => float div;
            0.0 => float x;
            for (int i; i < k; i++) {
                x + div => x;
                Math.pow(x, exp) => w_up[i];
            }
            len => dur_up;
        }

        if (which == 1) {
            k => w_down.size;
            1.0/k => float div;
            1.0 => float x;
            for (int i; i < k; i++) {
                x - div => x;
                Math.pow(x, exp) => w_down[i];
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
