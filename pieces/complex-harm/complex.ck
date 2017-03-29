// Eric Heep
// March 28th, 2017
// complex.ck

QDT q[2];
CDT c[2];
DP d[2];

WinFuncEnv wq[2];
WinFuncEnv wc[2];
WinFuncEnv wd[2];

adc => Listener l;
l.listen(1);
l.fidelity(0.5);

2.00 => float decibelThreshold;
1.00 => float schmittThreshold;
0 => int playing;

q[0] => wq[0] => dac.chan(0);
q[1] => wq[1] => dac.chan(1);
c[0] => wc[0] => dac.chan(2);
c[1] => wc[1] => dac.chan(3);

c[0].f2Gain(0.0);
q[1].f1Gain(0.0);
c[0].f2Gain(0.0);
q[1].f1Gain(0.0);

c[0].f1Gain(0.0);
c[1].f1Gain(0.0);
c[0].f2Gain(0.0);
c[1].f2Gain(0.0);

fun void setRatios(float r) {
    for (0 => int i; i < 2; i++) {
        q[i].ratio(r);
        c[i].ratio(r);
    }
}

setRatios(1.21);

// time to clear out
500::ms => now;

while (true) {
    check();
    100::ms => now;
    <<< "Freq:", l.freqMean(), 1.0 - l.freqStd(), "Dec:", l.dbMean(), l.dbStd() >>>;
}

fun void check() {
    if (l.dbMean() > decibelThreshold) {

        now => time past;
        <<< "-~-~ Listening -~-~-~-~-~--~-~-~-~-~--~-~-~-~-~-", "" >>>;
        while (l.dbMean() > schmittThreshold) {
            <<< "-~-~ Listening", l.freqMean(), 1.0 - l.freqStd(), "Dec:", l.dbMean() >>>;
            100::ms => now;
        }
        now - past => dur duration;

        <<< "-~-~ Playing -~-~-~-~-~-~--~-~-~-~-~--~-~-~-~-~-", "" >>>;
        <<< "-~-~ Freq:", l.freqMean(), 1.0 - l.freqStd(), "Dec:", l.dbMean() >>>;
        playDistortionTones(duration);
    }
}

fun void playDistortionTones(dur env) {

    env/2.0 => dur halfEnv;

    for (0 => int i; i < 2; i++) {
        wq[i].attack(halfEnv);
        wc[i].attack(halfEnv);
        wq[i].release(halfEnv);
        wc[i].release(halfEnv);
    }

    l.freqMean() => float freq;

    1 => playing;
    for (0 => int i; i < 2; i++) {
        q[i].freq(freq);
        c[i].freq(freq);

        wq[i].keyOn();
        wc[i].keyOn();
    }

    halfEnv => now;

    for (0 => int i; i < 2; i++) {
        wq[i].keyOff();
        wc[i].keyOff();
    }
    halfEnv => now;

    0 => playing;
}
