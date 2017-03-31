// Eric Heep
// March 29th, 2017
// complex-const-harm.ck

// input ~-
adc => Listener l;
l.listen(1);
l.fidelity(0.5);

2 => int NUM_DPS;

// OscOut out;
// out.dest("127.0.0.1", 12000);

// fun void playing(int idx) {
//     out.start("/p");
//     out.add(idx);
//     out.send();
// }

// fun void stopping(int idx) {
//     out.start("/s");
//     out.add(idx);
//     out.send();
// }

// qdts ~-
QDT q[NUM_DPS];

// quadratic distorion tone ratiods ~-
[1.111, 1.112, 1.113, 1.114, 1.115, 1.116] @=> float lowRatios[];
[1.111, 1.125, 1.428, 1.660, 1.200, 1.250] @=> float highRatios[];
lowRatios @=> float ratios[];

// envelopes ~-
ADSR env[NUM_DPS];
ADSR gate;
gate.attackTime(10::ms);
gate.releaseTime(10::ms);

// parameters
8.0 => float offsetDivide;
0.0 => float easingGain;
0.0 => float easingFreq;

0.0 => float confidence;
0.0 => float easingConfidence;

10::ms => dur attack;
500::ms => dur maxGateLength;
50::ms => dur maxHitLength;
25::ms => dur speed;
0.0 => float total;
0 => int slowActive;

for (0 => int i; i < NUM_DPS; i++) {
    env[i].attackTime(10::ms);
    q[i] => gate => env[i] => dac.chan(i);
    q[i].gain(1.0);
    q[i].freq(0.0);
}

// Markov ~-
Markov markov;

1 => int order;
6 => int range;

[2, 0, 3, 1, 4, 2, 5, 3, 5, 2, 4, 1, 3, 0] @=> int base[];
markov.generateTransitionMatrix(base, order, range) @=> float transitionMatrix[][];
int inputChain[NUM_DPS][base.size()];

for (int i; i < NUM_DPS; i++) {
    base @=> inputChain[i];
}

fun void hit(int idx, dur s, int which) {
    env[idx].releaseTime(s);
    env[idx].keyOn();
    q[idx].ratio(ratios[which]);
    attack => now;
    env[idx].keyOff();
    s - attack => now;

}

fun void queueAll(dur s, int which) {
    s/offsetDivide=> dur offsetSpeed;

    for (0 => int i; i < NUM_DPS; i++) {
        hit(i, s, inputChain[i][which]);
    }
}

fun void updateEasing() {
    while (true) {
        if (l.dbMean() > 10.0) {
            if (easingGain < 1.0) {
                0.0004 +=> easingGain;
            }
        } else if(easingGain > 0.0){
            0.0001 -=> easingGain;
        }
        if (easingConfidence < confidence) {
            0.001 +=> easingConfidence;
        } else if(easingGain > confidence){
            0.001 -=> easingConfidence;
        }
        if (easingFreq < l.freqMean() + 0.1) {
            0.125 +=> easingFreq;
        }
        else if (easingFreq > l.freqMean() - 0.1) {
            0.125 -=> easingFreq;
        }
        25::ms => now;
    }
}

fun void gating() {
    gate.keyOn();
    while (true) {
        1.0 - easingGain => float speedMultiplier;

        speedMultiplier * maxGateLength * 0.3 => dur gateLength;
        speedMultiplier * Math.random2f(0.0, 1.0) * maxGateLength * 0.7 +=> dur randLength;

        if (speedMultiplier > 0.025 && !slowActive) {
            gate.keyOff();
            gateLength + randLength + attack => now;
            gate.keyOn();
            speedMultiplier * Math.random2f(0.0, 1.0) * maxGateLength * 0.7 +=> randLength;
            gateLength + randLength + attack => now;
        }
        1::samp => now;
    }
}

spork ~ gating();
spork ~ updateEasing();
spork ~ uiPrint();

string uiPrintOutput;
string prevUiPrintOutput;
["~", "*", "-"] @=> string possibilities[];

fun void updatePrint(string lis, float gn, float frq, float eFrq, float eGn, float tot)
{
    string temp;
    " | Listening: " + lis + " " + uiFiller(gn) + " " +=> temp;
    " Gain: " + format(eGn, 4) + " " + uiFiller(eGn) + " " +=> temp;
    " Freq: " + format(frq, 5) + " " + uiFiller(frq/1000.0) + " " +=> temp;
    " FllwFreq: " + format(eFrq, 5) + " " + uiFiller(eFrq/1000.0) + " " +=> temp;
    " Tot: " + format(tot, 4) + " " + uiStraight(tot) + " " + "|" +=> temp;
    temp => uiPrintOutput;
}

fun string uiFiller(float f) {
    string filler;
    for (0 => int i; i < 25; i++) {
        if (Math.random2f(0.0, 1.0) < f) {
            possibilities[Math.random2(0, possibilities.size() - 1)] +=> filler;
        }
        else {
            " " +=> filler;
        }
    }
    return filler;
}

fun string uiStraight(float f) {
    string filler;
    for (0 => int i; i < 25; i++) {
        if (f * 25 > i) {
            possibilities[Math.random2(0, possibilities.size() - 1)] +=> filler;
        }
        else {
            " " +=> filler;
        }
    }
    return filler;
}

fun void uiPrint() {
    while (true) {
        0.1::second => now;
        if (uiPrintOutput != prevUiPrintOutput) {
            <<< uiPrintOutput, "" >>>;
            uiPrintOutput => prevUiPrintOutput;
        }
    }
}

fun string format(float val, int precision) {
    " " => string p;
    return (val + p).substring(0, precision);
}

int input;
int whichTime;
0.0004 => float totalInc;
[0.5, .7, 85] @=> float newTotal[];

// 0.01 => float totalInc;
[30, 60, 100] @=> int times[];

while (true) {
    1.0 - Std.clampf(l.freqStd(), 0.0, 500.0)/500.0 => confidence;
    " " => string lis;

    for (0 => int i; i < NUM_DPS; i++) {
        q[i].gain(easingGain);
        if (l.dbMean() > 10.0) {
            totalInc +=> total;
            "X" => lis;
            for (0 => int i; i < ratios.size(); i++) {
                (highRatios[i] - lowRatios[i]) * confidence + lowRatios[i] => ratios[i];
            }
        }
        q[i].freq(easingFreq);
        markov.generateChain(base, transitionMatrix, order, range) @=> inputChain[i];
    }

    // going through the Markov chain
    (input + 1) % base.size() => input;
    queueAll(speed, input);

    updatePrint(lis, l.dbMean()/100.0, l.freqMean(), easingFreq, easingGain, total);

    if (total > 1.0) {
        1 => slowActive;
        gate.keyOn();

        for (int i; i < NUM_DPS; i++) {
            env[i].keyOn();
        }
        100::ms => now;

        for (int i; i < NUM_DPS; i++) {
            env[i].releaseTime(whichTime::second * (2/3));
        }

        (times[whichTime])/3 => int remainderTime;
        times[whichTime] - remainderTime => int onTime;

        <<< " | ", "" >>>;
        <<< " | -~Countdown ~-", "" >>>;

        for (onTime => int i; i > 0; i--) {
            <<< " | ", i + remainderTime, "" >>>;
            1::second => now;
        }

        for (int i; i < NUM_DPS; i++) {
            env[i].releaseTime(remainderTime::second);
            env[i].keyOff();
        }

        for (remainderTime => int i; i > 0; i--) {
            <<< " | ", i, "" >>>;
            1::second => now;
        }

        <<< " | ", "" >>>;

        newTotal[whichTime] => total;

        whichTime++;
        if (whichTime == 3) {
            me.exit();
        }

    }
}
