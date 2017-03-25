// for_ann.ck
// Eric Heep

// A recreation of James Tenney's "For Ann (rising)."
// This recreation uses the the golden mean instead of a JI minor sixth.
// the result is that each first order difference tone reinforces the
// sine wave below it.

// Initial analysis of the piece was done in Python using music
// information retrieval techniques to closely approximate the
// parameters that Tenney used.

// ~~~~ the following parameters are based off of the analysis

// range of frequencies
// 20hz to 14250hz
20.0 => float min_frq;
14250.0 => float max_frq;

// slope of ascension
// 3.074 cents per millisecond over exactly 37 seconds
0.003074 => float pitch_inc;

// max voices heard at a time ~13, using 15 for no overlap
30 => int voices;

// envelope parameters:
// 160ms => attack (BH)
// 80ms => decay (BH)
// 36.74 => release (Exp)
160::ms => dur attack;
80::ms => dur decay;
36.74::second => dur release;

// limit of the fibonacci series, the golden mean
1.618033988749894 => float golden_mean;

// inverse of the golden mean, for finding notes below rather than above
1.0/golden_mean => float inverse;

// total number of sine waves:
240 => int num_sines;

// ~~~~ the rest of the code is standard ChucK

// oscillators
SinOsc sin[voices];
ADSR env[voices];
Gain master => dac;

for (int i; i < voices; i++) {
    // sound chain
    sin[i] => env[i] => master;
    sin[i].gain(0.0);

    // sets window type
    //env[i].attackCurve(2.0);
    //env[i].decayCurve(0.5);
    env[i].sustainLevel(0.9);
    //env[i].releaseCurve(0.5);

    // attack and release
    env[i].attackTime(attack);
    env[i].decayTime(decay);
    env[i].releaseTime(release);
}

// latch to ensure each sine wave starts once
int latch[voices];
int print_inc, offset, total, end;

// frquency control variables
14 => float pitch;
float hz[voices];
float base;

// function that recalculates the frequency values every millisecond
fun void assignFreq() {
    base => float frq;

    // array calculation, ensures all the sine waves are exactly
    // a golden ratio away from each other
    for (int i; i < voices; i++) {
        frq => hz[(i + offset) % voices];
        frq * inverse => frq;
    }

    // assigning frequencies to oscillators
    for (int i; i < voices; i++) {
        if (hz[i] >= min_frq && latch[i] != 1 && total < num_sines) {
            1 => latch[i];
            spork ~ play(i);
        }
        sin[i].freq(hz[i]);
    }
    // uncomment to show frequencies while the program is running
    // printHz();
}

// sanity function that ensures proper logic and calculations
fun void printHz() {
    string print;

    (print_inc + 1) % 100 => print_inc;
    if (print_inc == 0) {
        // appends frequencies throughout the array
        for (int i; i < voices; i++) {
            print + " " + Math.round(sin[i].freq()) => print;
        }
        <<< print, "" >>>;
    }
}

// raises the overal pitches syncronously at 3.074 per millisecond
fun void raisePitch() {
    pitch + pitch_inc => pitch;
    if (base > max_frq) {
        Std.ftom(base * inverse) => pitch;
        offset++;
    }
    Std.mtof(pitch) => base;
}

// generates a sine wave with the approximate envelope based off
// of the original, called after the value of the hz array passes 20hz
fun void play(int which) {
    // ensures only 240 sine waves are called
    total++;

    // sin phase sync
    sin[which].phase(0.0);

    // variable gain can be used to avoid clipping
    sin[which].gain(0.1);
    <<< "Playing Sine Wave:", total >>>;

    // main envelope, where all the sound comes from
    env[which].keyOn();
    attack + decay => now;
    env[which].keyOff();
    release + ms => now;
    sin[which].gain(0.0);

    // re-enables latch per sine wave
    0 => latch[which];
    end++;
}

fun void main() {
    while (end < num_sines - 1) {
        raisePitch();
        assignFreq();
        1::ms => now;
    }
    // breathing room at the end
    2::second => now;
}

// runs program until 240 sine waves have completed
main();
