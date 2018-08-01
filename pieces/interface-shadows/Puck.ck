// Puck.ck
// communication

public class Puck{
    HandshakeID talk;
    int port;

    fun void init(int which) {
        IDCheck(which) => port;
    }

    // tells child class to only send serial messages
    // if it has successfully connected to a matching robot
    fun int IDCheck(int arduinoID) {
        -1 => int check;
        for (int i; i < talk.talk.robotID.cap(); i++) {
            if (arduinoID == talk.talk.robotID[i]) {
                <<< "Puck", talk.talk.robotID[i], "connected to port", i + "." >>>;
                i => check;
            }
        }
        if (check == -1) {
            <<< "unable to connect">>>;
        }
        return check;
    }

    // receives OSC and sends out serial
    fun void color(int led, int hue, int sat, int val) {
        // ensuring the proper values get sent
        hue % 1024 => hue;
        Std.clamp(sat, 0, 255) => sat;
        Std.clamp(val, 0, 255) => val;

        talk.talk.packet(port, led, hue, sat, val);
    }
}
