public class Tape extends Chubgraph {
    inlet => ADSR e => Delay del => Gain g => ADSR off => outlet;
    g => del;

    e.set(500::ms, 0::ms, 1.0, 500::ms);
    off.set(100::ms, 0::ms, 1.0, 100::ms);

    int loop_active, rec_active;
    delay(1.5::second);

    fun void delay(dur d) {
        del.max(d);
        del.delay(d);
    }

    fun void loop(int l) {
        if (l) {
            1 => loop_active;
            spork ~ looping();
        }
        if (l == 0) {
            0 => loop_active;
        }
    }

    fun void looping() {
        off.keyOn();
        while (loop_active) {
            1::samp => now;
        }
        off.keyOff();
    }

    fun void rec(int r) {
        if (r) {
            1 => rec_active;
            spork ~ recording();
        }
        if (r == 0) {
            0 => rec_active;
        }
    }

    fun void recording() {
        e.keyOn();
        while (rec_active) {
            1::samp => now;        
        }
        e.keyOff();
    }
}
