// Micro.ck
// Eric Heep
// live sampling class centered around micro loops

public class Micro extends Chubgraph{
    // sound chain
    inlet => LiSa mic => outlet;

    // scoped variables
    int active;
    2.0::second => dur length;
    40::ms => dur ramp;

    int mncols;
    int mnrows[0];

    int x, y;

    fun void rampTime(dur r) {
        r => ramp;
    }

    fun void loopTime(dur len) {
        len => length; 
    }

    fun void size(int ncols, int nrows[]) {
        ncols => mncols;
        nrows @=> mnrows;
    }

    fun void loop(int k) {
        if (k == 1) {
            1 => active;
            spork ~ looping();
        }
        if (k == 0) {
            0 => active; 
        }
    }

    fun void move() {
        if (y < mnrows[x] - 1) {
            y++;
        }
        else {
            (x + 1) % mncols => x;
            0 => y;
        }
        if (Math.random2f(0.0,1.0) > 0.7) {
            (x + 1) % mncols => x;
            if (y >= mnrows[x]) {
                mnrows[x] - 1 => y;
            }
        }
    } 

    fun void looping () {
        length => mic.duration;
        mic.record(1);
        length => now;
        mic.record(0);
        mic.play(1);
        while (active) {
            move();
            mic.rampUp(ramp);
            length - ramp => now;
            mic.rampDown(ramp);
            ramp => now;
        }
        mic.play(0);
    }
}
