// NanoKontrol2.ck
// March, 2019

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

public class NanoKontrol2 {
    NanoEvent solo[9];
    NanoEvent mute[9];
    NanoEvent rec[9];

    NanoEvent knob[9];
    NanoEvent slider[9];

    NanoEvent play, forward, record, stop;

    MidiIn min;
    MidiMsg msg;
    min.open("nanoKONTROL2");

    spork ~ receive();

    fun void receive() {
        while (true) {
            // waits on midi events
            min => now;
            while (min.recv(msg)) {
                convert(msg.data1, msg.data2, msg.data3);
            }
        }
    }

    fun void convert (int data1, int data2, int data3) {
        if (data1 == 176) {
            for (int i ;i < 9; i++) {
                if (data2 == 0 + i) {
                    slider[i].setNote(data3);
                    slider[i].signal();
                }
                if (data2 == 16 + i) {
                    knob[i].setNote(data3);
                    knob[i].signal();
                }
                if (data2 == 32 + i) {
                    solo[i].setNote(data3);
                    solo[i].signal();
                }
                if (data2 == 48 + i) {
                    mute[i].setNote(data3);
                    mute[i].signal();
                }
                if (data2 == 64 + i) {
                    rec[i].setNote(data3);
                    rec[i].signal();
                }
            }
            if (data2 == 41) {
                play.setNote(data3);
                play.signal();
            }
            if (data2 == 42) {
                stop.setNote(data3);
                stop.signal();
            }
            if (data2 == 44) {
                forward.setNote(data3);
                forward.signal();
            }
            if (data2 == 45) {
                record.setNote(data3);
                record.signal();
            }
        }
    }
}
