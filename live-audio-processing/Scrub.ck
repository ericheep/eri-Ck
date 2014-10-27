public class Scrub extends Chubgraph {
    inlet => LiSa mic => outlet;

    dur rec_time, length;
    int rec_active;
    duration(8::second);

    fun void duration(dur l) {
        l => length;
    }

    fun void scrub(float pos) {
        mic.play(1);
        mic.playPos(((pos * rec_time/samp) $ int)::samp);
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
        mic.duration(length);
        mic.record(1);
        now => time past;
        while (rec_active) {
            1::samp => now;        
        }
        now => time present;
        present - past => rec_time;
        mic.record(0);
        mic.play(1);
    }
}
