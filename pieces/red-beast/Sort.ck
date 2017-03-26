// Sort.ck

public class Sort extends Chubgraph {
    // sound chain
    inlet => LiSa mic => outlet;
    
    dur step_dur, running_time;
    int rec_active, play_active;
    int max, min, inc, direction;
    int hard_max;
    int arg[0];

    maxDuration(30::second);
    stepDuration(50::ms);

    fun void maxPos(float m) {
        (m * arg.cap()) $ int => max;
    }
    
    fun void minPos(float m) {
        (m * arg.cap()) $ int => min;
    }

    // step duration
    fun void stepDuration(dur s) {
        s => step_dur;
    }

    // max buffer size
    fun void maxDuration(dur d) {
        mic.duration(d);
    }
    
    // index sorting 
    fun int[] argSort(float x[]) {
        int idx[x.cap()];
        for (int i; i < x.cap(); i++) {
           float max;
           int idx_max;
           for (int j; j < x.cap(); j++) {
                if (x[j] >= max) {
                    x[j] => max;
                    j => idx_max;
                }
            }
            idx_max => idx[i];
            0 => x[idx_max];
        }
        return idx;
    }

    // math
    fun int[] findMeans(dur s) {  
        (running_time/s) $ int => int div;
        float means[0];
        
        s/div => dur chunk;

        // finds the means of segments
        for (int i; i < div; i++) {
            float sum;
            for (int j; j < div; j++) {
                Math.fabs(mic.valueAt((j + (i * div)) * chunk)) +=> sum; 
            }
            means << sum/(s/ms);
        }
        return argSort(means);
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
        arg.cap() => hard_max;
        while(play_active) {
            mic.rampUp(20::ms);
            if (inc < arg.cap() || inc > -1) {
                //<<< "Inc:", inc, "Min", min, "Max:", max, "" >>>;
                mic.playPos(step_dur * arg[inc]); 
            }
            step_dur - 20::ms => now;
            mic.rampDown(20::ms);
            20::ms => now;

            direction +=> inc;
            if (inc == hard_max - 1 || inc == max) {
                -1 => direction; 
            }
            if (inc == 0 || inc == min) {
                1 => direction;
            }
        }
        mic.play(0);
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
        mic.recPos(running_time);
        mic.record(1);

        now => time past;
        while (rec_active) {
            1::samp => now;
        }
        now => time present;
        mic.record(0);
        present - past +=> running_time;
        findMeans(step_dur) @=> arg;
    }
}

/*
adc => Sort s => dac;

s.record(1);
1000::ms => now;
s.record(0);

s.play(1);
1::second => now;
s.play(0);

s.record(1);
10000::ms => now;
s.record(0);

s.play(1);

while (true) {
    1::second => now;
}
*/
