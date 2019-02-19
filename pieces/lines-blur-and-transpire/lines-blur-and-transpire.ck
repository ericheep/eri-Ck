// main.ck

class ES8Note {
    ES8 es8;
    Step volt => dac.left;
    SinOsc lfo => blackhole;
    lfo.freq(0.00);
    0.05 => float lfoMaxSpeed;
    0.22 => float lfoMaxAmount;

    float note, lfoSpeed, lfoAmount;

    fun void changeNote(int midiNote) {
        midiNote => note;
    }

    fun void changeLfoSpeed(float x) {
        x * lfoMaxSpeed => lfoSpeed;
        <<< lfoSpeed >>>;
    }

    fun void changeLfoAmount(float y) {
        y * lfoMaxAmount => lfoAmount;
        <<< lfoAmount >>>;
    }

    fun void setVolt() {
        while (true) {
            lfo.last() * lfoAmount => float pitchOffset;
            es8.pitch(0, note - 48.73 + pitchOffset) => float v;
            volt.next(v);
            10::samp => now;
        }
    }

    spork ~ setVolt();
}

ES8Note es8Note;
NanoKEYStudio n;

fun void noteEvents() {
    while (true) {
        n.key => now;
        es8Note.changeNote(n.key.getNote());
    }
}

fun void xEvents() {
    while (true) {
        n.x => now;
        es8Note.changeLfoSpeed(n.x.getNoteFloat());
    }
}

fun void yEvents() {
    while (true) {
        n.y => now;
        es8Note.changeLfoAmount(n.y.getNoteFloat());
    }
}

fun void clipEvents() {
    while (true) {
        n.pad => now;
        <<< n.pad.getNote() >>>;
    }
}

fun void main() {
    spork ~ noteEvents();
    spork ~ xEvents();
    spork ~ yEvents();
    spork ~ clipEvents();

    while(true) { second => now; }
}

main();
