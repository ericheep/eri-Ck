// NanoKEYStudio.ck

// event midi class
// February, 2019

class NanoEvent extends Event {
    0 => int noteOn;
    0 => int note;
    0 => int velocity;

    fun void setNoteOn(int o) {
        o => noteOn;
    }

    fun void setNote(int n) {
        n => note;
    }

    fun void setVelocity(int v) {
        v => velocity;
    }

    fun int getNote() {
        return note;
    }

    fun int getVelocity() {
        return velocity;
    }

    fun float getNoteFloat() {
        return note/127.0;
    }

    fun float getVelocityFloat() {
        return velocity/127.0;
    }

    fun float getNoteFloat(float pow) {
        note/127.0 => float f;
        return Math.pow(f, pow);
    }

    fun float getVelocityFloat(float pow) {
        velocity/127.0 => float f;
        return Math.pow(f, pow);
    }
}

public class NanoKEYStudio {
    MidiIn min;
    MidiMsg msg;
    min.open("nanoKEY Studio KEYBOARD/CTRL");

    spork ~ listen();

    NanoEvent y, x, xy, key, pad;
    NanoEvent knob[8];

    144 => int noteOn;
    128 => int noteOff;

    fun void listen() {
        while (true) {
            min => now;
            while (min.recv(msg)) {
                read(msg.data1, msg.data2, msg.data3);
            }
        }
    }

    [43, 48, 50, 49, 36, 38, 42, 46] @=> int padIndices[];

    fun void read(int data1, int data2, int data3) {
        if (data1 != 248 && data2 != 0 && data3 != 0) {
            if (data1 == 176) {
                if (data2 == 16) {
                    x.setNoteOn(data1);
                    x.setNote(data3);
                    x.signal();
                }
                if (data2 == 17) {
                    y.setNoteOn(data1);
                    y.setNote(data3);
                    y.signal();
                }
                if (data2 == 18) {
                    xy.setNoteOn(data1);
                }
                for (0 => int i; i < padIndices.size(); i++) {
                    if (data2 == padIndices[i]) {
                        pad.setNoteOn(data1);
                        pad.setNote(i);
                        pad.setVelocity(data3);
                        pad.signal();
                    }
                }
                for (0 => int i; i < knob.size(); i++) {
                    if (data2 == i + 20) {
                        knob[i].setNoteOn(data1);
                        knob[i].setNote(data2);
                        knob[i].setVelocity(data3);
                        knob[i].signal();
                    }
                }
            } else if (data1 != 176) {
                if (data3 == 127) {
                    x.setNoteOn(data1);
                    x.setNote(data2);
                    x.signal();
                }
                if (data2 >= 48 && data2 <= 120) {
                    key.setNoteOn(data1);
                    key.setNote(data2);
                    key.setVelocity(data3);
                    key.signal();
                }
            }
        }
    }
}

/* NanoKEYStudio n; */

/* // handler */
/* while( true ) { */
/*     n.key[0] => now; */
/*     <<< n.key[0].getNote(), n.key[0].getVelocityFloat(2) >>>; */
/* } */
