// sampler.ck
MrOtto otto;
otto.initSerial();

GVerb reverb;
Pan2 p, p2;
Gain gain;
LiSa mic[8];
LiSa grain[8];
LiSa chop[2];

Noise noise => HPF lp => dac;
SinOsc nois => ADSR env => dac;
SinOsc sin;
SinOsc bass => ADSR bassEnv => dac;
env.set(10::ms, 10::ms, 0.05, 10::ms);
bassEnv.set(10::ms, 10::ms, 0.05, 10::ms);

nois.gain(0.025);
100 => bass.freq;
0.0 => sin.gain;
0.0 => bass.gain;
0.0 => noise.gain;

for (int i; i < 2; i++) {
    0.7 => chop[i].gain;
    adc => chop[i] => p2;
}

for (int i; i < 8; i++) {
    0.8 => mic[i].gain;
    0.1 => grain[i].gain;
    adc => mic[i] => gain;
    adc => grain[i] => reverb => gain;
}
gain => p => dac;; 
p2 => dac;
sin;

OscOut osc;
osc.dest("127.0.0.1", 12001);

int chopSwtch[2];
int swtch[16];
int mute, hold, rate, scaleSend, colorSend, eventSwtch, reverseSwtch;
float vol, pan, pitch;

1200 => int measureMS;
measureMS::ms => dur measure;

fun void tone() {
    5000 => sin.freq;
    sin.gain(0.08);
    10::ms => now;
    sin.gain(0.0);
}

fun void chopper(int k) {
    measure => chop[k].duration;
    chop[k].record(1);
    (measure * 2.0) => now;
    chop[k].record(0);
    chop[k].play(1);
    while (otto.combo[k] == 1) {
        p2.pan(Math.random2f(-0.6, 0.4));
        Math.random2(100,500)::ms => dur step;
        Math.random2(500, measureMS)::ms - step => dur start;    
        chop[k].playPos(start);
        chop[k].rampUp(step/8);
        (step * 7/8) => now;
        chop[k].rampDown(step/8);
        step/8 => now;
    }
    chop[k].play(0);
}

fun void grainer(int k) {
    measure => grain[k].duration;
    grain[k].record(1);
    (measure/(k + 1)) => now;
    (k + 1) * 50 => int steps;
    ((measure/samp) $ int)/(steps) => int grainSize;
    grain[k].record(0);
    grain[k].play(1);
    while (otto.button[k] == 1) {
        grain[k].playPos((Math.random2(0,steps) * grainSize)::samp);
        grain[k].rampUp((grainSize * 0.5)::samp);
        (grainSize * 0.5)::samp => now;
        grain[k].rampDown((grainSize * 0.5)::samp);
        (grainSize * 0.5)::samp => now;
    }
    grain[k].play(0);
}

fun void pulser(int k) {
    measure => mic[k].duration;
    mic[k].record(1);
    (measure/(k + 4)) => now;
    mic[k].record(0);
    mic[k].play(1);
    while (otto.button[k + 8] == 1) {
        lines(k);
        1.0 => float j;
        (otto.accell[0]/300.0 + 0.5) => float pulseRoll;        
        if (pulseRoll < 1.0) {
            pulseRoll => j;
        }
        if (rate == 1) {
            0::ms => mic[k].playPos;
            mic[k].rate(1.0);
        }
        else {
            measure/(k + 4) => mic[k].playPos;
            mic[k].rate(-1.0);
        }
        if (pulseRoll > 1.0) {
            p.pan(Math.random2f((pulseRoll - 1) * 2, (pulseRoll - 1) * -2));
        }
        mic[k].rampUp((measure/(k + 4) * j) * 1/6);
        ((measure/(k + 4) * j) * 5/6) => now;
        mic[k].rampDown((measure/(k + 4) * j) * 1/6);
        ((measure * 1.0/(k + 4) * j) * 1/6) => now;
    }
    mic[k].play(0);
}

fun void loop() {
    while (true) {
        for (int i; i < 8; i++) {
            if (otto.button[i] == 1 && swtch[i] == 0) {
                1 => swtch[i];
                spork ~ grainer(i);
            }
            if (otto.button[i] == 0 && swtch[i] == 1) {
                0 => swtch[i];
            }
            if (otto.button[i + 8] == 1 && swtch[i + 8] == 0 ) {
                1 => swtch[i + 8];
                spork ~ pulser(i);
            }
            if (otto.button[i + 8] == 0 && swtch[i + 8] == 1) {
                0 => swtch[i + 8];
            }
        }    
        1::ms => now;
    }
}

fun void backwards() {
    (otto.accell[1]/300.0 * -1.0 + 1.0) => pitch;
    if (pitch < 0.2 && reverseSwtch == 0) {
        1 => reverseSwtch;
        0 => rate;
        reverse();
    } 
    else {
        0 => reverseSwtch;
        1 => rate;
    }
}

fun void panner() {
    ((otto.accell[0]/300.0 - 0.5) * 2.0) * -1.0 => pan;
    if (pan < 0.98 && pan > -0.98) {
        pan => p.pan;
    }
}

fun void control() {
    while (true) {
        for (int i; i < 2; i++) {
            if (otto.combo[i] == 1 && chopSwtch[i] == 0) {
                1 => chopSwtch[i];
                spork ~ chopper(i);
            }
            if (otto.combo[i] == 0 && chopSwtch[i] == 1) {
                0 => chopSwtch[i];
            }
        }
        if (otto.event[2] == 1 && eventSwtch == 0) {
            reset();
            1 => eventSwtch;
        }
        if (otto.event[2] == 0 && eventSwtch == 1) {
            0 => eventSwtch;
        }
        backwards();
        scale();
        color();
        50::ms => now;
    }
}

spork ~ loop();
spork ~ control();

while (true) {
    if (scaleSend == 0) {
        
    }
    if (scaleSend == 1) {
        sinPercussion(0.7);
    }
    if (scaleSend == 2) {
        noisePercussion(0.3);
    }
    measure => now;
}

fun void noisePercussion(float chance) {
    for (int i; i < 16; i++) {
        if (Math.random2f(0.0,1.0) > chance) {
            env.keyOn();
            noise.gain(0.005);
        }
        lp.freq(Math.random2f(1400,2000));
        measure/16 => now;
        noise.gain(0.0);
        env.keyOff();
    }
}

fun void sinPercussion(float chance) {
    for (int i; i < 16; i++) {
        if (Math.random2f(0.0,1.0) > chance) {
            env.keyOn();
            bassEnv.keyOn();
        }
        measure/16 => now;
        env.keyOff();
        bassEnv.keyOff();
    }
}

// osc functions
fun void lines(int k) {
    if (k == 0) {
        se();
    }
    if (k == 1) {
        sw();
    }
    if (k == 2) {
        ne();
    }
    if (k == 3) {
        nw();
    }
    if (k == 4) {
        left();
    }
    if (k == 5) {   
        right();
    }
    if (k == 6) {
        up();
    }
    if (k == 7) {
        down();
    }
}

fun void up() {
    osc.start("/upLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void down() {
    osc.start("/downLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void left() {
    osc.start("/leftLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void right() {
    osc.start("/rightLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void nw() {
    osc.start("/nwLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void ne() {
    osc.start("/neLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void sw() {
    osc.start("/swLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void se() {
    osc.start("/seLine");
    osc.add(Math.random2(0,20));
    osc.send();
}

fun void reset() {
    osc.start("/reset");
    osc.send();
}

fun void reverse() {
    osc.start("/reverse");
    osc.send();
}

fun void color() {
    if (otto.event[0] != colorSend) {
        otto.event[0] => colorSend;
        osc.start("/color");
        osc.add(colorSend);
        osc.send();
        spork ~ tone();
    }
}

fun void scale() {
    if (otto.event[1] != scaleSend) {
        otto.event[1] => scaleSend;
        osc.start("/scale");
        osc.add(scaleSend + 1);
        osc.send();
    }
}