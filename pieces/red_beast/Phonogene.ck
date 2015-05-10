// Phonogene.ck
// Eric Heep
// live sampling class inspired by Make Noise's Phonogene
// http://www.makenoisemusic.com/phonogene.shtml

public class Phonogene extends Chubgraph {
    // sound chain
    inlet => LiSa mic => outlet;

    // slice array
    dur slc[0];

    // scoped variables
    1.0 => float rte;
    float pos, grain_size, grain_pos;
    int overdub_active, play_active, rec_active, pos_button;

    dur env_time, rec_time, grain_time, loop_time, end, begin;
    8::second => dur length;

    grainSize(1.0);
    grainPos(0.5);
    feedback(1.0);

    // bidirectionality
    fun void bi(int b) {
        mic.bi(1);
    }

    // clears audio buffer and slice array
    fun void clear() {
        if (slc.size() > 2) {
            0 => slc.size;
            slc << 0::samp;
            slc << rec_time;
        }
        else {
            mic.play(0);
            mic.clear();
            slc.clear();
        }
    }

    // allocate memory for audio
    fun void duration(dur l) {
        l => length;
    }

    fun void grainSize(float g) {
        g => grain_size;
    }

    fun void grainPos(float g) {
        g => grain_pos;
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
            grain_time => now;
            sliceReset();
        }
        mic.play(0);
    }

    fun void overdub(int o) {
        if (o) {
            1 => overdub_active;
            spork ~ overdubbing();
        }
        if (o == 0) {
            0 => overdub_active;
        }
    }

    fun void overdubbing() {
        mic.playPos() => dur pos;
        mic.recPos(pos);
        mic.record(1);
        while(overdub_active) {
            1::samp => now;
        }
        mic.record(0);
    }

    fun void feedback(float o) {
        mic.feedback(o);
    }

    fun void rate(float r) {
        if (r != 0) {
            1.0/Math.fabs(r) => rte;
        }
        mic.rate(r);
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
        // empties the slice array
        slc.clear();

        // clears buffer and parameters
        mic.duration(length);
        mic.loop(1);
        mic.record(1);
        now => time past;
        while (rec_active) {
            1::samp => now;        
        }
        now => time present;
        mic.record(0);
        present - past => rec_time;
        mic.loopEnd(rec_time);
        rec_time => loop_time;

        // begining and end for slice duration array
        slc << 0::samp;
        slc << rec_time;
    }

    // internal function, reoders array
    fun dur[] sort(dur x[]) {
        dur out[x.cap()];
        int sum;
        while (sum != x.cap() - 1) {
            0 => sum;
            for (int i; i < x.cap() - 1; i++) {
                if (x[i] > x[i + 1]) {
                    x[i] => dur temp;
                    x[i + 1] => x[i];
                    temp => x[i + 1];
                }
                else {
                    sum++;
                }
            } 
        }
        return x;
    }

    fun void slice() {
        slc << mic.playPos();
        sort(slc) @=> slc;
    }

    fun void slicePos(int p) {
        if (p == 1) {
            pos_button++;
        }
        if (p == 0) {
            pos_button--;
        }
        pos_button % (slc.size() - 1) => pos_button;
        if (slc.size() > 1) {
            slc[Math.abs(pos_button)]/rec_time => pos;
        }
    }

    fun void slicePos(float p) {
        p => pos; 
    }

    fun void sliceReset() {
        if (slc.size() > 1) {
            pos * rec_time => dur temp_pos;
            for (int i; i < slc.cap() - 1; i++) {
                if (temp_pos >= slc[i] && temp_pos <= slc[i + 1]) {
                    if (grain_size == 0) {
                        0.005 => grain_size;
                    }
                    slc[i + 1] - slc[i] => loop_time;
                    (1.0 - grain_size) * grain_pos * loop_time => dur offset;
                    grain_size * slc[i + 1] + offset + slc[i] => end;
                    slc[i] + offset => begin;
                    mic.loopStart(begin);
                    mic.loopEnd(end);
                    (end - begin) * rte => grain_time;
                }
            }
        }
    }
}
