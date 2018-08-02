// give it some time to breathe
HandshakeID talk;
0.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
0.5::second => now;

5 => int NUM_PUCKS;
16 => int NUM_LEDS;
Puck pucks[NUM_PUCKS];
Pulse pulses[NUM_PUCKS];
RandomPulse randomPulses[3];

// midi class
NanoKontrol2 nano;

for (0 => int i; i < randomPulses.size(); i++) {
    randomPulses[i].init(NUM_PUCKS);
}

SinOsc sin[3];

for (0 => int i; i < 3; i++) {
    sin[i] => blackhole;
    sin[i].freq(Math.random2f(0.1, 0.2));
}

// Puck assignments to ports
for (0 => int i; i < NUM_PUCKS; i++) {
    pucks[i].init(i);
    pulses[i].init(NUM_LEDS);
}


fun void set(float arr[], float v) {
    for (0 => int i; i < NUM_LEDS; i++) {
        v => arr[i];
    }
}

fun void setAll(float arr[][], float v) {
    for (0 => int i; i < NUM_PUCKS; i++) {
        for (0 => int j; j < NUM_LEDS; j++) {
            v => arr[i][j];
        }
    }
}

fun void randomColors(float hues[][], float sats[][], float vals[][]) {
    for (0 => int i; i < NUM_PUCKS; i++) {
        for (0 => int j; j < NUM_LEDS; j++) {
            Math.random2f(0.0, 1.0) => hues[i][j];
            1.0 => vals[i][j];
            1.0 => sats[i][j];
        }
    }
}

fun float[] randomValue(float vals[]) {
    for (0 => int i; i < NUM_LEDS; i++) {
        Math.random2f(0.0, 1.0) => vals[i];
    }

    return vals;
}

fun int convert(float input, float scale) {
    return Math.floor(input/1.0 * scale) $ int;
}

fun void updatePucks(Puck pucks[], float hue[][], float sat[][], float val[][]) {
    for (0 => int i; i < pucks.size(); i++) {
        sendColors(pucks[i], hue[i], sat[i], val[i]);
    }
}

fun void sendColors(Puck puck, float hue[], float sat[], float val[]) {
    for (0 => int i; i < NUM_LEDS; i++) {
        puck.color(i,
            convert(hue[i], 1023),
            convert(sat[i], 255),
            convert(val[i], 255)
        );
    }
}


fun void sinMovement(float vals[][], float hues[][], float sats[][], int numPucks, int row[], SinOsc sin, float val, float sat) {
    (sin.last() + 1.0) * 0.5 => float pos;
    (numPucks * row.size() * pos)$int => int whichLED;

    whichLED / row.size() => int whichPuck;
    whichLED % row.size() => int whichLocalLED;

    if (whichPuck == numPucks) numPucks - 1 => whichPuck;

    val +=> vals[whichPuck][row[whichLocalLED]];
    0.8 => hues[whichPuck][row[whichLocalLED]];
    sat => sats[whichPuck][row[whichLocalLED]];
}

fun void updateRandomPulse(dur pulseDurs[], int numActiveLEDs[], float pulseVals[], dur totalDur[]) {
    for (0 => int i; i < 3; i++) {
        nano.slider[i]/127.0 => float slider;
        nano.knob[i]/127.0 => float knob;

        Math.pow(slider, 0.25) => pulseVals[i];
        totalDur[i] - (knob * knob * (totalDur[i] - 0.05::second)) => pulseDurs[i];
        (slider + knob) * 0.5 => float both;
        (Math.pow(both, 3) * 16 * NUM_PUCKS)$int => numActiveLEDs[i];
    }
}

fun void updateSinMovement(float sinVals[], float sinSats[]) {
    for (0 => int i; i < 3; i++) {
        nano.slider[i + 3]/127.0 => float slider;
        nano.knob[i + 3]/127.0 => float knob;

        Math.pow(knob, 4) * 5.0 + 0.05 => sin[i].freq;
        Math.pow(slider, 2) => sinVals[i];

    }

    3.0 - nano.slider[6]/127.0 * 3.0 => float slider;
    if (slider > 0.0) {
        slider => sinSats[0];
    }
    if (slider > 1.0) {
        slider - 1.0 => sinSats[1];
    }
    if (slider > 2.0) {
        slider - 2.0 => sinSats[2];
    }

}

fun void updateBlink(float vals[][]) {
    nano.slider[7]/127.0 => float slider;
    if (Math.pow(slider, 3) > Math.random2f(0.0, 1.0)) {
        setAll(vals, 0.0);
    }
}

fun void main(int numPucks, int numLEDs, dur updateRate) {
    float hues[numPucks][numLEDs];
    float sats[numPucks][numLEDs];
    float vals[numPucks][numLEDs];

    [15, 14, 13, 12, 11] @=> int top[];
    [10,  9,  8,  7,  6,  5] @=> int middle[];
    [ 4,  3,  2,  1,  0] @=> int bottom[];

    setAll(sats, 1.0);

    dur randomPulseDurs[3];
    int randomActiveLEDs[3];
    float randomPulseVals[3];

    float sinVals[3];
    float sinSats[3];

    [5.482::second, 6.123::second, 4.624::second] @=> dur totalDurs[];

    while (true) {
        nano.knob[6]/127.0 => float knob;
        setAll(vals, Math.pow(knob, 0.25));
        setAll(hues, 0.85);

        nano.slider[6]/127.0 * 3.0 => float sat;

        if (sat >= 2.99) {
            setAll(sats, 0.0);
        }

        updateRandomPulse(randomPulseDurs, randomActiveLEDs, randomPulseVals, totalDurs);
        updateSinMovement(sinVals, sinSats);

        randomPulses[0].pulse(randomPulseDurs[0], randomActiveLEDs[0], vals, hues, randomPulseVals[0], 0.0);
        randomPulses[1].pulse(randomPulseDurs[1], randomActiveLEDs[1], vals, hues, randomPulseVals[1], 0.7);
        randomPulses[2].pulse(randomPulseDurs[2], randomActiveLEDs[2], vals, hues, randomPulseVals[2], 0.85);

        sinMovement(vals, hues, sats, numPucks, top, sin[0], sinVals[0], sinSats[0]);
        sinMovement(vals, hues, sats, numPucks, middle, sin[1], sinVals[1], sinSats[1]);
        sinMovement(vals, hues, sats, numPucks, bottom, sin[2], sinVals[2], sinSats[2]);

        updateBlink(vals);

        if (nano.play) {
            randomColors(hues, sats, vals);
        }

        for (0 => int i; i < NUM_PUCKS; i++) {
            if (nano.m[i]) {
                set(vals[i], 0.0);
            }
        }

        updatePucks(pucks, hues, sats, vals);
        updateRate => now;

    }
}

main(NUM_PUCKS, NUM_LEDS, (1.0/30.0)::second);
