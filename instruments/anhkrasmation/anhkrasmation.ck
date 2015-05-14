Quneo q;

// play with modulation gain, maybe saw mod, other stuff
// feedback fm, in mod and carrier, mod for the mod, etc.
// ring mod of the mod, chebychev wavetable stuff

// number of pads
16 => int num;
SinOsc sin[num];
Noise n => 
LPF filt[num];
SinOsc mod[num];
Noise nois => dac;
PowerADSR env[num];

nois.gain(0.0);
// master gain
Gain m;

for (int i; i < num; i++) {
    n => filt[i] => mod[i];
    sin[i].gain(0.8);
    sin[i] => env[i] => m;
    mod[i] => sin[i]; 
    2 => sin[i].sync;
    env[i].set(10::ms, 0::samp, 1.0, 100::ms);
    env[i].setCurves(2.0, 0.5, 0.5);
}

// master gain
m.gain(0.0);
m => dac;

// KEYON/KEYOFF CONTROLS 

int pad_latch[16];
float freq[16];
float freq_note[2];
float freq_add[2];

float sin_gain[16];
float current_sin_gain[16];

int slider[8];
int midi_toggle, play_latch;

fun void pad() {
    for (int i; i < 16; i++) {
        if (q.pad(i) > 0 && pad_latch[i] == 0) {
            env[i].attack((q.pad(i, "x")/127.0 * 4.0)::second + 100::ms);
            env[i].keyOn();
            sin[i].freq(freq[i]);
            mod[i].freq(freq[i] * (slider[5]/127.0 * 4.0 + 1.0));
            filt[i].freq(freq[i] * (slider[6]/127.0 * 4.0 + 1.0));
            1 => pad_latch[i];
        }
        if (q.pad(i) > 0) {
            env[i].release((q.pad(i, "y")/127.0 * 4.0)::second + 100::ms);
        }
        if (q.pad(i) == 0 && pad_latch[i] == 1) {
            0 => pad_latch[i];
            env[i].keyOff();
        }
        if (current_sin_gain[i] < sin_gain[i]) {
            0.005 +=> current_sin_gain[i];
            sin[i].gain(current_sin_gain[i]);
        }
        if (current_sin_gain[i] > sin_gain[i]) { 
            0.005 -=> current_sin_gain[i];
            sin[i].gain(current_sin_gain[i]);
        }
    }
}


fun void controls() {
    if (q.play() > 0 && play_latch == 0) {
        (midi_toggle + 1) % 2 => midi_toggle;
        1 => play_latch;
    }
    if (q.play() == 0 && play_latch == 1) {
        0 => play_latch;
    }

    for (int i; i < 8; i++) {
        if (midi_toggle) {
            for (int j; j < 16; j++) {
                Std.mtof(60 + j) => freq[j];
            }
        }
        else {
            if (i < 2) {
                if (q.slider(i) != slider[i]) {
                    q.slider(i) => slider[i];
                    if (i % 2 == 0) {
                        slider[i]/127.0 * 4000 + 55 => freq_add[0];
                    }
                    else {
                        slider[i] => freq_note[0];
                    }
                    for (int j; j < 8; j++) {
                        Std.mtof(freq_note[0]/4.0) + j * (freq_add[0] + 10) => freq[j + 8]; 
                    }
                }
            }
            if (i >= 2 && i < 4) {
                if (q.slider(i) != slider[i]) {
                    q.slider(i) => slider[i];
                    if (i % 2 == 0) {
                        slider[i]/127.0 * 4000 + 55 => freq_add[1];
                    }
                    else {
                        slider[i] => freq_note[1];
                    }
                    for (int j; j < 8; j++) {
                        Std.mtof(freq_note[1]/4.0) + j * (freq_add[1] + 10) => freq[j]; 
                    }            
                }
            }
        }
        if (i == 4) {
            if (q.slider(i) != slider[i]) {
                q.slider(i) => slider[i];
                for (int j; j < 16; j++) {
                    sin[j].gain(slider[i]/127.0 * 0.5);
                }
            }
        }
        if (i == 5) {
            if (q.slider(i) != slider[i]) {
                q.slider(i) => slider[i];
                for (int j; j < 16; j++) {
                    mod[j].gain(slider[i]/127.0 * 5000);
                }
            }
        }
        if (i == 6) {
            if (q.slider(i) != slider[i]) {
                q.slider(i) => slider[i];
                for (int j; j < 16; j++) {
                    filt[j].gain(slider[i]/127.0 * 5000);
                }
            }
        }
        if (i == 7) {
            if (q.slider(i) != slider[i]) {
                q.slider(i) => slider[i];
                nois.gain(slider[i]/127.0 * 1.0);
            }
        }
    }
}


// MASTER GAIN CONTROLS

int master_fader;
float master_gain, current_gain;

fun void master() {
    if (q.fader() != master_fader) {
        q.fader() => master_fader;
        master_fader/127.0 => master_gain;
    }
    if (current_gain < master_gain) {
        0.001 +=> current_gain;
        m.gain(current_gain); 
    }
    if (current_gain > master_gain) {
        0.001 -=> current_gain;
        m.gain(current_gain); 
    }
}

// MAIN LOOP

while (true) {
    pad();
    controls();
    master();
    1::ms => now;
}

