public class Micro extends Chubgraph{
    inlet => LiSa mic => outlet;

    int active;
    8.0::second => dur length;
    100::ms => dur ramp;

    fun void rampTime(dur r) {
        r => ramp;
    }

    fun void loopTime(dur len) {
        len => length; 
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

    fun void looping () {
        length => mic.duration;
        mic.record(1);
        length => now;
        mic.record(0);
        mic.play(1);
        while (active) {
            mic.rampUp(ramp);
            length - ramp => now;
            mic.rampDown(ramp);
            ramp => now;
        }
        mic.play(0);
    }
}
