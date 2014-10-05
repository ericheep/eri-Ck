public class Binary {
    16 => int max;

    SinOsc sin[max];
    ADSR env[max];
    MultiPan mp[max];

    for (int i; i < max; i++) {
        sin[i] => env[i] => mp[i];
        0 => sin[i].gain;
    }


    dur release;
    0.5 => float vol;
    float left, right, speed;
    int active, mode;

    adsr(30::ms, 0::ms, 1.0, 30::ms);

    fun void adsr(dur a, dur d, float s, dur r) {
        for (int i; i < env.cap(); i++) {
            env[i].set(a, d, s, r);        
        }
        r => release;
    }

    fun void gain(float v) {
        v => vol;
    }   

    fun void randomPan() {
        randomPan(-1.0, 1.0);
    }
    
    fun void randomPan(float l, float r) {
        2 => mode;
        l => left;
        r => right;
    }

    fun void rotate(float l, float r) {
        rotate(l, r, 1.0);
    }

    fun void rotate(float l, float r, float s) {
        1 => mode;
        s => speed; 
        l => left;
        r => right;
    }

    fun void spread(float l, float r) {
        0 => mode;
        l => left;
        r => right;
    }

    fun void panning(int m, int b, float l, float r, float s, dur len) {
        float pos[b];
        Math.fabs(l - r) => float d;
        for (int i; i < b; i++) {
            if (l > r) {
                l - i/(b - 1.0) * d => pos[i]; 
            }
            if (r > l) {
                l + i/(b - 1.0) * d => pos[i]; 
            }
            if (l == r) {
                l => pos[i];
            }
        }
        // spread mode
        if (m == 0) {
            for (int i; i < b; i++) {
                pos[i] => mp[i].pan;
            }
        }
        // rotate mode
        if (m == 1) {
            spork ~ rotating(m, b, l, r, s, len, pos);
        }
        // random mode
        if (m == 2) {
            for (b - 1 => int i ;i >= 0; i--) {
                 Math.random2f(l, r) => mp[i].pan;
            }
        }
    }

    fun void rotating(int m, int b, float l, float r, float s, dur len, float p[]) {
        1 => active;
        float sum, val;
        (r - l) => float d;
        ((2.0 * pi)/(len/ms)) * s => float inc;
        while (active == 1) {
            for (int i; i < b; i++) {
                Math.sin(p[i] + sum) => val;
                // maps values to left and right parameters
                (val + 1.0) * d / 2.0 + l => mp[i].pan;
            }
            inc + sum => sum;
            1::ms => now;
        }
    }

    fun void play(float fund, int val, dur length) {
        play(fund, val, 1, length);
    }

    fun void play(float fund, int val, int octaves, dur length) {
        bitCalc(val) => int bit;

        for (int i; i < max; i++) {
            0 => sin[i].gain;
        }

        binaryCalc(bit, val) @=> int binary[];
        
        for (int i; i < bit; i++) {
            fund * Math.pow(Math.pow(octaves + 1.0, 1.0/(bit - 1)),i) => float x;
            x => sin[i].freq;
            (binary[bit - (i + 1)] * vol) * (0.5/(bit + 1)) => sin[i].gain;
            env[i].keyOn();
        }
        
        // calls panning
        panning(mode, bit, left, right, speed, length);

        length - release => now;
        for (int i; i < bit; i++) {
            env[i].keyOff();
        }
        release => now;
        
        0 => active;

        for (int i; i < bit; i++) {
            sin[i] =< mp[i];
        }
    }

    fun int bitCalc(int val) {
        int bit;
        1 => int mlt;
        while (mlt <= val) {
            2 *=> mlt;
            bit++;
        }
        return bit;
    }

    fun int valCalc(int bit, int val) {
        Math.pow(2, bit) $ int +=> val;
        return val;
    }

    fun int[] binaryCalc(int bit, int val) {
        int binary[bit];
        int quotient, remainder;

        val => int compare;
        for (int i; i < bit; i++) {
            compare / 2 => quotient;
            compare % 2 => remainder;
            if (remainder == 0) 0 => binary[i];
            else {
                1 => binary[i];
            }
            quotient + remainder => int subtract;
            compare - subtract => compare;
        }
        return binary;
    }

    fun void print(int binary[]) {
        string p;
        for (int i; i < binary.cap(); i++) {
            binary[i] + p => p; 
        }
        <<< p >>>;
    }
}
