// Probability Chopper
// '`' to record, 'p' to playback, and 'r' to reset probability
// -~-~-~-~-~-~
// Eric Heep
// December 7th, 2013

// sound chain
adc => LiSa mic => NRev rev => dac;
adc => dac;
0.1 => rev.mix;

// hid setup
Hid hi;
HidMsg msg;
0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< hi.name() + " is fully operational.", "">>>;

// variables
8::second => dur measureTime;
32 => float divisions;
32 => float perc;
divisions $ int => int div;
measureTime/divisions => dur stepTime;
float prob;
dur stepPos;
int j, recOff;

while (true) {
    hi => now;
    while (hi.recv(msg)) {
        if (msg.isButtonDown()) {
            if (msg.ascii == 96) {
                0 => recOff;
                spork ~ record();
            }
            if (msg.ascii == 80) {
                spork ~ chopper();
            }
            if (msg.ascii == 82) {
                0 => j;
            }
        }
        if (msg.isButtonUp()) {
            if (msg.ascii == 96) {
                1 => recOff;
            }
        }
    }
}

fun void record() {
    measureTime => mic.duration;
    1 => mic.record;
    <<< "------------------------------", "" >>>;
    <<< "Recording", "" >>>;
    now => time past;
    while (recOff == 0) {
        1::samp => now;
    }
    now => time present;
    present - past => dur recTime;
    0 => mic.record;
    <<< "Recorded for", recTime/second, "seconds." >>>;
    <<< "------------------------------", "" >>>;
    recTime/divisions => stepTime;
}

fun void chopper() {
    j => float chance;
    j++;
    <<< "Playing with a", chance/perc * 100, "percent chance to chop.", "" >>>;
    for (int i; i < divisions; i++) {
        Math.random2f(0,perc) => prob;
        if (prob < j) {
            Math.random2(0,div - 1) * stepTime => stepPos;
        }
        else {
            i * stepTime => stepPos;
        }
        1 => mic.play;
        stepPos => mic.playPos;
        stepTime => now;
        0 => mic.play;
    }
}