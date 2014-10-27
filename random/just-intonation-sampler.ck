// JustIntonationKeyboard.ck
[90,83,88,68,67,86,71,66,72,78,74,77,
 81,50,87,51,69,82,53,84,54,89,55,85,73] @=> int notes[];

[1.0, 25.0/24.0, 9.0/8.0, 6.0/5.0, 5.0/4.0, 4.0/3.0,
45.0/32.0, 3.0/2.0, 8.0/5.0, 5.0/3.0, 9.0/5.0, 15.0/8.0,
2.0] @=> float just[];

Hid key;
HidMsg msg;
int mode, device;
if (me.args())me.arg(0) => Std.atoi => device;

// if no keyboard is present, the program will exit
if (!key.openKeyboard(device))me.exit();
<<< "Keyboard '" + key.name() + "' is activated!","">>>;

// array with ascii values for two octaves
int hold[notes.cap()];

fun void other_play(int note) {
    SinOsc s => ADSR e => dac;
    e.set( 10::ms, 8::ms, .5, 4000::ms );
    //sin[note].freq(Std.mtof(note + 60));
    if (mode == 0) s.freq(440.0 * just[note]);
    if (mode == 1) s.freq(Std.mtof(note + 69));
    s.gain(0.5);
    e.keyOn();
    while (hold[note] == 1) {
        1::samp => now;
    }
    e.keyOff();
    4000::ms => now;
    s.gain(0.0);
}
while (true) {
    // waits for a keyboard message
    key => now;
    while (key.recv(msg)) {
        if (msg.isButtonDown()) {
            for (int i; i < 25; i++) {
                if (msg.ascii == notes[i]) {
                    <<< i >>>;
                    1 => hold[i];
                    spork ~ other_play(i);
                }
            }
            if (msg.ascii == 96) {
                (mode + 1) % 2 => mode;
                if (mode == 0) <<< "JI Mode", "" >>>;
                else <<< "ET Mode", "" >>>;
            }
        }
        if (msg.isButtonUp()) {
            for (int i; i < 25; i++) {
                if (msg.ascii == notes[i]) {
                    0 => hold[i];
                }
            }
        }
    }
}
