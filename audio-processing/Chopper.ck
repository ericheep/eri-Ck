// Eric Heep
// March 23rd, 2017
// Chopper.ck


public class Chopper extends Chubgraph {

    inlet => LiSa mic => outlet;

    int div, play_active, rec_active;
    1 => int sl;

    dur m_record, chop_time, chop_pos;
    0::ms => dur m_rampTime;

    maxLength(16::second);

    fun void maxLength(dur l) {
        mic.duration(l);
    }

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
            1 => m_play;
            spork ~ playing();
        }
        if (p == 0) {
            0 => m_play;
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

    fun void rampTime(float r) {
        r => ramp_time;
    }

    fun void record(int r) {
        // clears buffer and parameters
        if (r) {
            1 => rec_active;
            spork ~ recording();
        }
        if (r == 0) {
            0 => rec_active;
        }
    }

    fun void recording() {
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
