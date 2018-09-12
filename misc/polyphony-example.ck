// Eric Heep
// Sept 12th, 2018


class FilterModule extends Chubgraph {
    inlet => LPF lpf => outlet;
    lpf.freq(1000);

    // do modulation stuff here
}

class BeepBoops extends Chubgraph {
    BlitSaw saw => HPF hpf => FilterModule filter => ADSR env => Pan2 pan => outlet;

    // probably good to define some instrumental parameters

    fun void setSawFreq(float f) {
        saw.freq(f);
    }

    fun void setHPFFreq(float f) {
        hpf.freq(f);
    }

    fun void setEnv(dur a, dur d, float s, dur r) {
        env.set(a, d, s, r);
    }

    fun void noteOn() {
        env.keyOn();
    }

    fun void noteOff() {
        env.keyOff();
    }
}

BeepBoops beepBoops[8];

fun void noteOn(BeepBoops beepBoop) {
    // do some instrument parameter setting
    Math.random2f(10.0, 30.0)::ms => dur ar;
    beepBoop.setEnv(ar, 0::samp, 1.0, ar);
    beepBoop.setSawFreq(Math.random2f(500.0, 1000.0));
    beepBoop.setHPFFreq(Math.random2f(500.0, 1000.0));

    // actually play it
    beepBoop.noteOn();
    (ar * 2.0) => now;
    beepBoop.noteOff();
}

for (0 => int i; i < beepBoops.size(); i++) {
    beepBoops[i] => dac;
}

0 => int whichBeepBoop;

while (true) {
    spork ~ noteOn(beepBoops[whichBeepBoop]);
    (whichBeepBoop + 1) % beepBoops.size() +=> whichBeepBoop;
    200::ms => now;
}

