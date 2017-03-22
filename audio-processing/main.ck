Gain g;
Gain fl;
Quneo q;
Phonogene ph[4];
Micro m[16];

int section;
int sSwtch;
int mSwtch[16];

[[0,1,2,3,4,5,6,7],
[8, 9,10,11,12,13,14,15],
[16,17,18,19,20,21,22,23],
[24,25,26,27,28,29,30,31]] @=> int padLeds[][];

[6, 4, 2, 0] @=> int buttonLeds[];

float grain_time[4];

for (int i; i < m.cap(); i++) {
    m[i].loopTime((15.625 * (i + 1))::ms);
    m[i].rampTime(((15.625/8.0) * (i + 1))::ms);
    adc => m[i] => dac.chan(0);
    m[i] => dac.chan(1);
    //m[i] => dac.chan(2);//2
    //m[i] => dac.chan(3);//3  
    m[i].gain(1.0);  
}

fl.gain(0.7);
//adc => fl => dac.chan(2);//2
for (int i; i < ph.cap(); i++) {
    ph[i].gain(0.25);
    adc => ph[i] => g => dac.chan(0);
    ph[i] => g => dac.chan(1);
    //ph[i] => g => dac.chan(3);//3
}

for (int i; i < ph.cap(); i++) {
    ph[i].bi(1);
}

int pos_f_swtch[ph.cap()];
int pos_b_swtch[ph.cap()];
int rec_swtch[ph.cap()];
int ovrdub_swtch[ph.cap()];
int slce_swtch[ph.cap()];
int clr_swtch[ph.cap()];
int prev_pos[ph.cap()];
int prev_rte[ph.cap()];
int grain_size, grain_pos, vol;
int which_grain, grain_select, grain_up_swtch, grain_down_swtch;

[7, 5, 3, 1] @=> int pos_f[];
[6, 4, 2, 0] @=> int pos_b[];
[0, 4, 8, 12] @=> int rec[];
[1, 5, 9, 13] @=> int ovrdub[];
[2, 6, 10, 14] @=> int slce[];
[3, 7, 11, 15] @=> int clr[];
[3, 2, 1, 0] @=> int pos[];
[6, 7, 8, 9] @=> int rte[];

[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15] @=> int padNum[];

fun void whichGrain() {
    if (q.button[9] > 0 && grain_up_swtch == 0) {
        which_grain++;
        1 => grain_up_swtch;
        Math.abs(which_grain % 4) => grain_select;
        <<< "Phonogene:", grain_select >>>;
        for (int i; i < 4; i++) {
            q.led(128, buttonLeds[i] + 36, 0);
        }
        q.led(144, buttonLeds[grain_select] + 36, 127);
    }
    if (q.button[9] == 0 && grain_up_swtch == 1) {
        0 => grain_up_swtch;
    }
    if (q.button[10] > 0 && grain_down_swtch == 0) {
        which_grain--;
        1 => grain_down_swtch;
        Math.abs(which_grain % 4) => grain_select;
        <<< "Phonogene:", grain_select >>>;
        for (int i; i < 4; i++) {
            q.led(128, buttonLeds[i] + 36, 0);
        }
        q.led(144, buttonLeds[grain_select] + 36, 127);
        
    }
    if (q.button[10] == 0 && grain_down_swtch == 1) {
        0 => grain_down_swtch;
    }
}

fun void grain() {
    if (q.slider[4] != grain_size) {
        q.slider[4]/127.0 => ph[grain_select].grainSize; 
        q.slider[4] => grain_size;
    }
    if (q.slider[5] != grain_pos) {
        q.slider[5]/127.0 => ph[grain_select].grainPos;
        q.slider[5] => grain_pos;
    }
}

fun void buttonPosition() {
    for (int i; i < ph.cap(); i++) {
        if (q.button[pos_f[i]] > 0 && pos_f_swtch[i] == 0) {
            1 => pos_f_swtch[i];
            ph[i].slicePos(1);
        }
        if (q.button[pos_f[i]] == 0 && pos_f_swtch[i] == 1) {
            0 => pos_f_swtch[i];
        }
        if (q.button[pos_b[i]] > 0 && pos_b_swtch[i] == 0) {
            1 => pos_b_swtch[i];
            ph[i].slicePos(0);
        }
        if (q.button[pos_b[i]] == 0 && pos_b_swtch[i] == 1) {
            0 => pos_b_swtch[i];
        }
    }
}

fun void gain() {
    
}

fun void rate() {
    for (int i; i < ph.cap(); i++) {
        if (q.slider[rte[i]] != prev_rte[i]) {
            q.slider[rte[i]]/127.0 * 2.0 - 1.0 => ph[i].rate;
            q.slider[rte[i]] => prev_rte[i];        
        }
    }
}

fun void record() {
    for (int i; i < ph.cap(); i++) {
        if (q.pad[rec[i]] > 0 && rec_swtch[i] == 0) {
            ph[i].play(0);
            ph[i].record(1);
            1 => rec_swtch[i];
        }
        if (q.pad[rec[i]] == 0 && rec_swtch[i] == 1) {
            ph[i].record(0);
            0 => rec_swtch[i];
            ph[i].play(1);
        }
    }
}

fun void overdub() {
    for (int i; i < ph.cap(); i++) {
        if (q.pad[ovrdub[i]] > 0 && ovrdub_swtch[i] == 0) {
            ph[i].overdub(1);
            1 => ovrdub_swtch[i];
        }
        if (q.pad[ovrdub[i]] == 0 && ovrdub_swtch[i] == 1) {
            ph[i].overdub(0);
            0 => ovrdub_swtch[i];
        }
    }
}

fun void clear() {
    for (int i; i < ph.cap(); i++) {
        if (q.pad[clr[i]] > 0 && clr_swtch[i] == 0) {
            ph[i].clear();
            1 => clr_swtch[i];
        }
        if (q.pad[clr[i]] == 0 && clr_swtch[i] == 1) {
            0 => clr_swtch[i];
        }
    }
}

fun void slice() {
    for (int i; i < ph.cap(); i++) {
        if (q.pad[slce[i]] > 0 && slce_swtch[i] == 0) {
            ph[i].slice();
            1 => slce_swtch[i];
        }
        if (q.pad[slce[i]] == 0 && slce_swtch[i] == 1) {
            0 => slce_swtch[i];
        }
    }
}

fun void volume() {
    if (q.fader != vol) {
        q.fader/127.0 => g.gain; 
        q.fader => vol;
    }
    for (int i; i < ph.cap(); i++) {
        if (q.slider[pos[i]] != prev_pos[i]) {
            q.slider[pos[i]]/127.0 => ph[i].gain;
            q.slider[pos[i]] => prev_pos[i];
        }
    }
}

fun void mic() {
    for (int i; i < m.cap(); i++) {
        if (q.pad[i] > 0 && mSwtch[i] == 0) {
            1 => mSwtch[i];
            m[i].loop(1);
        }
        if (q.pad[i] == 0 && mSwtch[i] == 1) {
            0 => mSwtch[i];
            m[i].loop(0);
        }
    }
}

fun void led() {
    while (true) {
        for (int i; i < 4; i++) {
            (second/ph[i].grain_time) => grain_time[i]; 
            (8.0/grain_time[i]/2.5) $ int => int chck;      
            if (chck > 8) {
                8 => chck;
            }
            for (int j; j < chck; j++) {
                q.led(144, padLeds[i][j], 127);
            }
            for (chck => int j; j < 8 - chck; j++) {
                q.led(128, padLeds[i][j], 0); 
            }            
        }
        100::ms => now; 
    }
}

spork ~ led();

while (true) {
    if (q.play > 0 && sSwtch == 0) {
        (section + 1) % 2 => section;
        1 => sSwtch;
    }
    if (q.play == 0 && sSwtch == 1) {
        0 => sSwtch;
    }
    if (section == 0) {
        buttonPosition();
        clear();
        record();
        slice();
        overdub();
        grain();
        rate();
        volume();
        whichGrain();
    }
    if (section == 1) {
        mic();
    }
    10::ms => now;
}
