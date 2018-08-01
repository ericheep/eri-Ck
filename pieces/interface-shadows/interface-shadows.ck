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

// midi class
// NanoKontrol2 n;

fun void set(float v, float arr[]) {
    for (0 => int i; i < NUM_LEDS; i++) {
        v => arr[i];
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


[15, 14, 13, 12, 11] @=> int top[];
[ 10,  9,  8,  7,  6,  5] @=> int middle[];
[ 4,  3,  2,  1,  0] @=> int bottom[];

fun void sinMovement(float val[][], int numPucks, int row[], SinOsc sin) {
    (sin.last() + 1.0) * 0.5 => float pos;
    (numPucks * row.size() * pos)$int => int whichLED;

    whichLED / row.size() => int whichPuck;
    whichLED % row.size() => int whichLocalLED;

    if (whichPuck == numPucks) numPucks - 1 => whichPuck;

    1.0 => val[whichPuck][row[whichLocalLED]];
}

[
    7::second,
    9::second,
    10::second,
    4::second,
    5::second,
    6::second
] @=> dur seconds[];

fun void main(int numPucks, int numLEDs, dur updateRate) {
    float hue[numPucks][numLEDs];
    float sat[numPucks][numLEDs];
    float val[numPucks][numLEDs];

    // moments of all off
    // moments of super bright all on
    // going pause going pause
    // white?
    // sin cycles
    // blue red shift

    while (true) {
        for (0 => int i; i < NUM_PUCKS; i++) {
            set(Math.random2f(0.0, 1.0), hue[i]);
            set(0.00, sat[i]);
            /* pulses[i].pulse(seconds[i], seconds[i], val[i], 0.0); */
            pulses[i].pulse(Math.random2f(0.01, 0.5)::second, 0::samp, val[i], 1.0);
            set(1.00, val[i]);
        }
        /* pulses[0].pulse(0.6::second, 0.6::second, val[0], 1.0); */

        sinMovement(val, numPucks, top, sin[0]);
        /* sinMovement(val, numPucks, middle, sin[1]); */
        /* sinMovement(val, numPucks, bottom, sin[2]); */

        updatePucks(pucks, hue, sat, val);
        updateRate => now;

    }
}

main(NUM_PUCKS, NUM_LEDS, (1.0/30.0)::second);
