// ChucK CasioSK-1-like Sampler with keyboard control
// -~-~-~-~-~-~
// Eric Heep
// Nov 4th, 2013
// mimics the sampling of a Casio SK-1 sampling keyboard, uses your
// computer for playback

// sound chain
adc => Gain in => OnePole pole => blackhole;
adc => LiSa mic => NRev rev => LPF lopass => dac;

// setting a few parameters
0 => rev.mix;
2000 => lopass.freq;
1 => lopass.Q;

// setting up keyboard controls
Hid key;
HidMsg msg;
0 => int device;
if (me.args())me.arg(0) => Std.atoi => device;

// if no keyboard is present, the program will exit
if (!key.openKeyboard(device))me.exit();
<<< "Keyboard '" + key.name() + "' is activated!","">>>;

// global variables
dur recTime;
3 => int ctr;
0 => int note;
0 => int modTwo;

// two dimensional array for translating values
int asciiToMidi[25][2];

// arrays with ascii values for two octaves
[90,83,88,68,67,86,71,66,72,78,74,77] @=> int asciiArrayA[];
[81,50,87,51,69,82,53,84,54,89,55,85,73] @=> int asciiArrayB[];

// populates arrays with ascii values
for (int i; i < 25; i++) {
    if (i < 12) {
        asciiArrayA[i] => asciiToMidi[i][0];
    }
    else {
        asciiArrayB[i - 12] => asciiToMidi[i][0];
    }   
    i => asciiToMidi[i][1];
}

// recorder
fun void record() {
    <<< "--------------------------------", "" >>>;
    // creates a new buffer each recording session, resets parameters
    8::second => mic.duration;
    40 => mic.maxVoices;
    1 => mic.record;
    now => time x;
    <<< "Started Recording at", x/second >>>;
    while (msg.isButtonDown()) {
        1::samp => now;
    }
    now => time y;
    <<< "Stopped Recording at", y/second >>>;
    0 => mic.record;
    y - x => recTime;
    <<< "Recorded for", recTime/second, "seconds" >>>;
}

fun void play(int rateNote) {
    // creates a new voice each playthrough
    mic.getVoice() => int newVoice;
    // discovered that there is a LiSa.pan object!
    // strangely enough, it pans between 0 and 1 instead of -1 to 1
    // set for 24 values to compliment two octaves of a keyboard
    mic.pan(newVoice,((rateNote + 1) * 0.03846));
    // 2^(1/12) = 1.059463, modified formula for equal temperment, which
    // translates directly to rate, omitted the frequency part
    // Q is the middle note here
    Math.pow(1.059463, (rateNote - 12)) => float x;
    mic.rate(newVoice, x);    
    mic.playPos(newVoice, 0::samp);
    mic.play(newVoice, 1);
    // the reciprocal of the rate is multiplied by the recording time
    // ensuring that each sample doesn't loop back around or is cut short
    recTime * 1 / x => now;
    mic.play(newVoice, 0);
}

while (true) {
    // waits for a keyboard message
    key => now;
    while (key.recv(msg)) {
        // converts ascii value to a value between 0 and 24
        0 => int check;
        for (int i; i < 25; i++) {
            if (asciiToMidi[i][0] == msg.ascii) {
                asciiToMidi[i][1] => note;
                check++;
            }
        }
        if (msg.isButtonDown() ) {
            // sets "'" to call the record function
            // hold for recording, release to stop
            if (msg.ascii == 96) {
                spork ~ record();
            }
            if (note >= 0 && note < 25 && check == 1) {
                spork ~ play(note);
            }
        }
    }
    1::samp => now;
}
