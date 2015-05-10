public class BlinkSin extends Chubgraph {

    inlet => MagicSine sin => ExpEnv env => outlet;

    int x1, y1;
    int x2, y2;

    10::ms => dur attack;
    55::ms => dur release;

    float frq;
    int x, y, active;

    int mncols;
    int mnrows[0];

    env.set(attack, 0::samp, 1, release); 
    env.setCurves(0.1, 0.5, 0.5);

    fun void freq(float f) {
        f => frq;
    }

    fun float blink(int m, int b) {
        if(m) move();
        if(b) {
            sin.freq(frq - y * 10);
            env.keyOn();
            attack => now;
            env.keyOff();
            release => now;

            env.keyOn();
            attack => now;
            env.keyOff();
            release => now;
        }

    }

    fun void attck(dur a) {
        a => attack;
    }

    fun void rlease(dur r) {
        r => release;
    }

    fun void size(int ncols, int nrows[]) {
        ncols => mncols;
        nrows @=> mnrows;

        Math.random2(0, mncols - 1) => x1;
    }


    fun void blinkPhrase(int b) {
        if (b == 1) {
            1 => active;
            spork ~ blinking();
        }
        if (b == 0) {
            0 => active;
        }
    }

    fun void blinking() {
        while (active) {
            blink(1, 1);
        }
    }

    fun void move() {
        if (y1 < mnrows[x1] - 1) {
            y1++;
        }
        else {
            (x1 + 1) % mncols => x1;
            0 => y1;
        }
        if (Math.random2f(0.0,1.0) > 0.7) {
            (x1 + 1) % mncols => x1;
            if (y1 >= mnrows[x1]) {
                mnrows[x1] - 1 => y1;
            }
        }
    }

    fun float[][] moveBlink(float arr[][], int ncols, int nrows[], int mode) {
        if (mode == 0) {
            if (y1 < nrows[x1] - 1) {
                y1++;
            }
            else {
                (x1 + 1) % ncols => x1;
                0 => y1;
            }
            1 => arr[x1][y1];
            y1 => y;
        }
        else if (mode == 1) {
            if (y2 < nrows[x2] - 1) {
                y2++;
            }
            else {
                (x2 + 1) % ncols => x2;
                0 => y2;
            }
            1 => arr[x2][y2];
            y2 => y;
        }
        frq - y => frq;
        return arr;
    }

    fun float[][] calc(float arr[][], int ncols, int nrows[]) {
        int col, row;
        Math.random2(0, ncols - 1) => col;
        Math.random2(0, nrows[col] - 1) => row;
        1 => arr[col][row];
        return arr;
    }
}
