Gain g;
Gain fl;
Quneo q;
Phonogene ph[4];
fl.gain(0.4);
// adc => fl => dac;
for (int i; i < ph.cap(); i++) {
    adc => ph[i] => g => dac;
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

fun void whichGrain() {
    if (q.button[9] > 0 && grain_up_swtch == 0) {
        which_grain++;
        1 => grain_up_swtch;
        Math.abs(which_grain % 4) => grain_select;
        <<< "Phonogene:", grain_select >>>;
    }
    if (q.button[9] == 0 && grain_up_swtch == 1) {
        0 => grain_up_swtch;
    }
    if (q.button[10] > 0 && grain_down_swtch == 0) {
        which_grain--;
        1 => grain_down_swtch;
        Math.abs(which_grain % 4) => grain_select;
        <<< "Phonogene:", grain_select >>>;
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

while (true) {
    buttonPosition();
    clear();
    record();
    slice();
    overdub();
    grain();
    rate();
    volume();
    whichGrain();
    10::ms => now;
}
