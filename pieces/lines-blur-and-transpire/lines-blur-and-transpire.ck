// main.ck

class ES8Note {
    ES8 es8;
    Step volt => dac.left;
    SinOsc lfo => blackhole;
    lfo.freq(0.00);
    0.05 => float lfoMaxTargetSpeed;
    0.22 => float lfoMaxAmount;

    float note, lfoSpeed, lfoTargetSpeed, lfoAmount, lfoTargetAmount;

    fun void changeNote(int midiNote) {
        midiNote => note;
    }

    fun void changeLfoTargetAmount(float y) {
        y * lfoMaxAmount => lfoTargetAmount;
    }

    fun void changeLfoTargetSpeed(float x) {
        x * lfoMaxTargetSpeed => lfoTargetSpeed;
    }

    fun void updateLfoSpeed() {
        0.00001 => float speedIncrement;
        while (true) {
            if (lfoSpeed < lfoTargetSpeed - speedIncrement) {
                speedIncrement +=> lfoSpeed;
            } else if (lfoSpeed > lfoTargetSpeed + speedIncrement) {
                speedIncrement -=> lfoSpeed;
            }
            if (lfoAmount < lfoTargetAmount - speedIncrement) {
                speedIncrement +=> lfoAmount;
            } else if (lfoAmount > lfoTargetAmount + speedIncrement) {
                speedIncrement -=> lfoAmount;
            }
            1::ms => now;
        }
    }

    spork ~ updateLfoSpeed();

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
        es8Note.changeLfoTargetSpeed(n.x.getNoteFloat());
    }
}

fun void yEvents() {
    while (true) {
        n.y => now;
        es8Note.changeLfoTargetAmount(n.y.getNoteFloat());
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
