public class NanoKontrol2 {

    int s[9];
    int m[9];
    int r[9];

    int knob[9];
    int slider[9];

    int port;
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
                    data3 => slider[i];
                }
                if (data2 == 16 + i) {
                    data3 => knob[i];
                }
                if (data2 == 32 + i) {
                    data3 => s[i];
                }
                if (data2 == 48 + i) {
                    data3 => m[i];
                }
                if (data2 == 64 + i) {
                    data3 => r[i];
                }
            }
        }
    }
}

NanoKontrol2 n;

while (true) {
    50::ms => now;
}
