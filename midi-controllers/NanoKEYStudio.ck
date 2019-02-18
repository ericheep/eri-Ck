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

    NanoEvent y, x;
    NanoEvent key[24];
    NanoEvent pad[8];
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

    fun void read(int data1, int data2, int data3) {
        if (data1 != 248 && data2 != 0 && data3 != 0) {
            if (data1 == 176) {
                if (data2 == 19) {
                    y.setNote(data3);
                    y.signal();
                }
                for (0 => int i; i < pad.size(); i++) {
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
                for (0 => int i; i < key.size(); i++) {
                    if (data2 == i + 48) {
                        key[i].setNoteOn(data1);
                        key[i].setNote(data2);
                        key[i].setVelocity(data3);
                        key[i].signal();
                    }
                }
                for (0 => int i; i < pad.size(); i++) {
                    if (data2 == i + 36) {
                        pad[i].setNoteOn(data1);
                        pad[i].setNote(data2);
                        pad[i].setVelocity(data3);
                        pad[i].signal();
                    }
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
