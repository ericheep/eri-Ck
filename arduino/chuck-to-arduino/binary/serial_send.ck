// Eric Heep
// serial_send.ck
// May 2016
// communication

public class Solenoid {
    // serial setup
    SerialIO serial;
    SerialIO.list() @=> string list[];

    // initialize
    fun void init() {
        int serial_port;

        for (int i; i < list.cap(); i++) {
            if (list[i].find("usb") > 0) {
                i => serial_port;
                <<< "Connected to", list[i] >>>;
            }
        }

        // serial connecting
        if (!serial.open(serial_port, SerialIO.B57600, SerialIO.BINARY)) {
            <<< "Unable to open serial device:", "\t", list[serial_port] >>>;
        }
        else {
            <<< list[serial_port], "assigned to port", serial_port, "" >>>;
        }

        2.0::second => now;
    }

    // note function
    fun void note(int num, int vel) {
        // allows note numbers 0-63 and note velocities 0-1023
        int bytes[3];
        255 => bytes[0];
        (num << 2) | (vel >> 8) => bytes[1];
        vel & 255 => bytes[2];
        serial.writeBytes(bytes);
    }
}

Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
if( !hi.openKeyboard( device ) )me.exit();

5 => int millisecond;
5 => int velocity;

fun void status() {
    <<< "Millisecond:\t", millisecond, "\tVelocity:\t", velocity >>>;
}

fun void keyboardControl() {
    while (true) {
        hi => now;
        while (hi.recv(msg)) {
            // 65 ms up,  83 ms down, 68 vel up,  70 vel down
            if (msg.isButtonDown()) {
                if (msg.ascii == 65) {
                    if (millisecond > 1) {
                        1 -=> millisecond;
                    }
                    status();
                }
                if (msg.ascii == 83) {
                    1 +=> millisecond;
                    status();
                }
                if (msg.ascii == 68) {
                    if (millisecond > 0) {
                        1 -=> velocity;
                    }
                    status();
                }
                if (msg.ascii == 70) {
                    1 +=> velocity;
                    status();
                }
            }
        }
    }
}

spork ~ keyboardControl();

Solenoid sol;
sol.init();

while (true) {
    sol.note(0, velocity);
    millisecond::ms => now;
}
