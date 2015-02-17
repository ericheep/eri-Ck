public class Chopper extends Chubgraph {

    inlet => LiSa mic => outlet;
    int div, play_active, rec_active;
    1 => int sl;

    dur rec_time, chop_time, chop_pos;
    100::ms => dur ramp_time;
    16::second => dur length;
   
    fun void divisions(int d) {
        d => div;
        if (div != 0 && div > 0) {
            rec_time/div => chop_time; 
        }
    }

    fun void slices(int s) {
        s => sl;
    }

    fun void duration(dur l) {
        l => length;
    }

    fun void play(int p) {
        if (p) {
            1 => play_active;
            spork ~ playing();
        }
        if (p == 0) {
            0 => play_active;
        }
    }

    fun void playing() {
        mic.play(1);
        while(play_active) {
            mic.rampUp(ramp_time);
            mic.playPos(Math.random2(0, sl) * chop_time);
            chop_time => now;
            if (sl != div) {
                sl => div;
                divisions(sl);
            }
            mic.rampDown(ramp_time);
            if (chop_time > ramp_time) {
                (chop_time - ramp_time) => now;
            }
        }
        mic.play(0);
    }

    fun void rampTime(dur r) {
        r => ramp_time;
    }

    fun void record(int r) {
        if (r) {
            1 => rec_active;
            spork ~ recording();
        }
        if (r == 0) {
            0 => rec_active;
        }
    }

    fun void recording() {
        // clears buffer and parameters
        mic.duration(length);
        mic.record(1);
        now => time past;
        while (rec_active) {
            1::samp => now;        
        }
        now => time present;
        mic.record(0);
        present - past => rec_time;
        mic.loopEnd(rec_time);
    }
}
