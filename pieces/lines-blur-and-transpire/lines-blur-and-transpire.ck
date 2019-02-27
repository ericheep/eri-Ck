// main.ck

class ClipEvent {
    ClipGroup groups[0];

    fun void addGroup(string filenames[], dur fadeIn, dur fadeOut) {
        ClipGroup group;
        group.setDir(me.dir() + "clips");
        group.setClips(filenames);
        group.setAttackRelease(fadeIn, fadeOut);

        groups << group;
        group => dac.chan(1);
    }

    fun void rotateGroup(int index, dur from, dur to, dur crossFade) {
        groups[index].rotate(from, to, crossFade);
    }

    fun void pauseGroup(int index, dur wait, dur from, dur to, dur fade, dur silence) {
        groups[index].pauses(wait, from, to, fade, silence);
    }

    fun void setGroupGain(int index, float g) {
        groups[index].setGain(g);
    }

    fun void play() {
        for (0 => int i; i < groups.size(); i++) {
            groups[i].play();
        }
    }

    fun void stop() {
        for (0 => int i; i < groups.size(); i++) {
            groups[i].stop();
        }
    }
}

ClipEvent clipEvents[8];

// cue 1
clipEvents[0].addGroup(
    ["pink.wav"],
    1::second, 160::second
);

// cue 2
clipEvents[1].addGroup(
    ["sine.wav"],
    23::second, 40::second
);
clipEvents[1].addGroup(
    ["radio-r-1.wav", "radio-r-2.wav", "radio-r-3.wav"],
    90::second, 60::second
);
clipEvents[1].rotateGroup(1, 6::second, 12::second, 5::second);
clipEvents[1].addGroup(
    ["ebow-noise-1.wav", "ebow-noise-2.wav"],
    90::second, 60::second
);

clipEvents[1].addGroup(
    ["metal-662hz.wav"],
    20::second, 60::second
);
clipEvents[1].pauseGroup(3, 0::second, 6::second, 12::second, 10::second, 15::second);
clipEvents[1].setGroupGain(3, 0.5);

clipEvents[1].addGroup(
    ["metal-515hz.wav"],
    150::second, 60::second
);
clipEvents[1].pauseGroup(4, 8::second, 6::second, 12::second, 10::second, 15::second);
clipEvents[1].setGroupGain(4, 0.25);

// cue 3
clipEvents[2].addGroup(
    ["radio-r-1.wav", "radio-r-2.wav", "radio-r-3.wav", "radio-r-4.wav", "radio-r-5.wav"],
    10::second, 60::second
);
clipEvents[2].rotateGroup(0, 30::second, 35::second, 15::second);
clipEvents[2].setGroupGain(0, 0.45);
clipEvents[2].addGroup(
    ["ebow-Db-4.wav"],
    10::second, 60::second
);
clipEvents[2].setGroupGain(1, 1.25);

// cue 4
clipEvents[3].addGroup(
    ["radio-r-1.wav", "radio-r-2.wav", "radio-r-3.wav", "radio-r-4.wav", "radio-r-5.wav"],
    10::second, 10::second
);
clipEvents[3].rotateGroup(0, 30::second, 35::second, 15::second);
clipEvents[3].setGroupGain(0, 0.45);

clipEvents[3].addGroup(
    ["metal-662hz.wav"],
    20::second, 20::second
);

clipEvents[3].pauseGroup(1, 0::second, 6::second, 12::second, 10::second, 10::second);
clipEvents[3].setGroupGain(1, 0.25);

clipEvents[3].addGroup(
    ["metal-515hz.wav"],
    20::second, 20::second
);
clipEvents[3].pauseGroup(2, 8::second, 6::second, 12::second, 10::second, 10::second);
clipEvents[3].setGroupGain(2, 0.25);

clipEvents[3].addGroup(
    ["ebow-Db-4.wav"],
    10::second, 40::second
);
clipEvents[3].setGroupGain(3, 1.25);

// cue 5
clipEvents[4].addGroup(
    ["radio-r-1.wav", "radio-r-2.wav", "radio-r-3.wav", "radio-r-4.wav", "radio-r-5.wav"],
    10::second, 340::second
);
clipEvents[4].rotateGroup(0, 30::second, 35::second, 15::second);
clipEvents[4].setGroupGain(0, 0.45);

clipEvents[4].addGroup(
    ["metal-662hz.wav"],
    20::second, 250::second
);
clipEvents[4].pauseGroup(1, 0::second, 6::second, 12::second, 10::second, 15::second);
clipEvents[4].setGroupGain(1, 0.25);

clipEvents[4].addGroup(
    ["metal-515hz.wav"],
    20::second, 250::second
);
clipEvents[4].pauseGroup(2, 8::second, 6::second, 12::second, 10::second, 15::second);
clipEvents[4].setGroupGain(2, 0.25);

clipEvents[4].addGroup(
    ["metal-74hz.wav"],
    20::second, 250::second
);
clipEvents[4].pauseGroup(3, 4::second, 6::second, 12::second, 10::second, 15::second);
clipEvents[4].setGroupGain(3, 0.25);

clipEvents[4].addGroup(
    ["ebow-Eb-B-14c.wav"],
    30::second, 250::second
);
clipEvents[4].setGroupGain(4, 1.25);
clipEvents[4].addGroup(
    ["ebow-G-Eb-14c.wav"],
    60::second, 220::second
);
clipEvents[4].setGroupGain(5, 1.25);

// cue 5
clipEvents[5].addGroup(
    ["erikas-noise.wav"],
    30::second, 90::second
);

class ES8Note {
    ES8 es8;
    Step volt => dac.chan(0);
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
            lfo.freq(lfoSpeed);
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

fun void padEvents() {
    -1 => int currentlyPlaying;
    while (true) {
        n.pad => now;
        n.pad.getNote() => int newPlaying;
        clipEvents[newPlaying].play();
        <<< "clipEvent", newPlaying + 1 >>>;
        if (currentlyPlaying >= 0) {
            clipEvents[currentlyPlaying].stop();
        }
        newPlaying => currentlyPlaying;
    }
}

fun void main() {
    spork ~ noteEvents();
    spork ~ xEvents();
    spork ~ yEvents();
    spork ~ padEvents();

    while(true) { second => now; }
}

main();
