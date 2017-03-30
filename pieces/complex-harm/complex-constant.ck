// Eric Heep
// March 29th, 2017

// input
adc => Listener l;
l.listen(1);
l.fidelity(0.5);

4 => int NUM_DPS;

// sound
QDT q[NUM_DPS];
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
500::ms => dur maxHitLength;
25::ms => dur changingSpeed;

for (0 => int i; i < NUM_DPS; i++) {
    env[i].attackTime(10::ms);
    q[i] => gate => env[i] => dac.chan(i);
    q[i].gain(1.0);
    q[i].freq(0.0);
}

// Markov
Markov markov;

1 => int order;
6 => int range;

[2, 0, 3, 1, 4, 2, 5, 3, 5, 2, 4, 1, 3, 0] @=> int base[];
markov.generateTransitionMatrix(base, order, range) @=> float transitionMatrix[][];

[1.111, 1.112, 1.113, 1.114, 1.115, 1.116] @=> float lowRatios[];
[1.111, 1.125, 1.428, 1.660, 1.200, 1.250] @=> float highRatios[];

lowRatios @=> float ratios[];

int inputChain[NUM_DPS][base.size()];

for (int i; i < NUM_DPS; i++) {
    base @=> inputChain[i];
}

25::ms => dur speed;

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
        spork ~ hit(i, s, inputChain[i][which]);
        offsetSpeed => now;
    }
}


fun void updateEasing() {
    while (true) {
        if (l.dbMean() > 10.0) {
            if (easingGain < 1.0) {
                0.00040 +=> easingGain;
            }
        } else if(easingGain > 0.0){
            0.00010 -=> easingGain;
        }
        if (easingConfidence < confidence) {
            0.001 +=> easingConfidence;
        } else if(easingGain > confidence){
            0.001 -=> easingConfidence;
        }
        25::ms => now;
        // <<< easingConfidence, confidence >>>;
    }
}

fun void gating() {
    gate.keyOn();
    while (true) {
        1.0 - easingConfidence => float speedMultiplier;
        (speedMultiplier) * maxHitLength => changingSpeed;

        speedMultiplier * maxGateLength * 0.3 => dur gateLength;
        speedMultiplier * Math.random2f(0.0, 1.0) * maxGateLength * 0.7 +=> dur randLength;

        if (speedMultiplier > 0.025) {
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

while (true) {
    1.0 - Std.clampf(l.freqStd(), 0.0, 500.0)/500.0 => confidence;

    for (0 => int i; i < NUM_DPS; i++) {
        q[i].gain(easingGain);
        if (l.dbMean() > 10.0) {
            <<< "Freq:", easingFreq, "Confidence:", confidence, "Gain:", easingGain >>>;
            for (0 => int i; i < ratios.size(); i++) {
                (highRatios[i] - lowRatios[i]) * confidence + lowRatios[i] => ratios[i];
            }

            if (easingFreq < l.freqMean() + 0.1) {
                0.025 +=> easingFreq;
            }
            else if (easingFreq > l.freqMean() - 0.1) {
                0.025 -=> easingFreq;
            }

            q[i].freq(easingFreq);
        }
        markov.generateChain(base, transitionMatrix, order, range) @=> inputChain[i];
    }
    for (0 => int i; i < base.size(); i++) {
        spork ~ queueAll(speed + changingSpeed, i);
    }
    speed + changingSpeed => now;
}
