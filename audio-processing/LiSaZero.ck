public class LiSaZero extends Chubgraph {

    inlet => LiSa mic => Gain g => outlet;

    dur buffer;

    fun void begin(dur len) {
        scan(len, 0);
    }

    fun void end(dur len) {
        scan(len, 1);
    }
    
    fun void scan(dur len, int which) {
        int idx;
        float val;

        // number of samples to iterate through
        (len/samp) $ int => int samps;

        // grabs current sample position and value
        mic.playPos() => dur pos;
        mic.valueAt(pos) => float min;

        // iterates through all the samples
        // and finds the minimum values
        for (1 => int i; i < samps; i++) {
            pos + i::samp => dur val_pos;

            if (val_pos <= buffer) {
                Std.fabs(mic.valueAt(val_pos)) => val;
            }
            else {
                <<< "!", val_pos, pos >>>;
            }

            //<<< pos + i::samp >>>;
            if (val < min) {
                val => min;        
                i => idx;
            }
        }
        spork ~ zero(idx, samps, which); 
    }

    fun void zero(int idx, int samps, int which) {
        for (int i; i < samps; i++) {
            if (i < idx && which == 0) {
                g.gain(0.0);
            }
            if (i > idx && which == 1) {
                g.gain(0.0);
            }
            1::samp => now;
        }
        g.gain(1.0);
    }

    fun void duration(dur d) {
        mic.duration(d);
        d => buffer;
    }

    fun void play(int p) {
        mic.play(p);
    }

    fun void playPos(dur p) {
        mic.playPos(p);
    }

    fun void record(int r) { 
        mic.record(r);
    }
    
}

adc => LiSaZero mic => dac;

50::ms => dur step;
1::second => dur rec_time;
100::samp => dur scan;

mic.duration(rec_time);

<<< "Record", "" >>>;
mic.record(1);
rec_time => now;
mic.record(0);

mic.play(1);
(rec_time/step) $ int => int num;
int pos;

while (true) {
    Math.random2(0, num - 1) => pos;
    mic.playPos(pos * step);

    mic.begin(scan);
    step - scan => now;
    mic.end(scan);
    scan => now;
}
