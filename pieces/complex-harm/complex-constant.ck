// Eric Heep
// March 29th, 2017

Markov markov;

QDT q1 => dac.left;
QDT q2 => dac.right;

q1.freq(440);
q2.freq(220);

q1.gain(0.1);
q2.gain(0.1);

1 => int order;
6 => int range;

[2, 0, 3, 1, 4, 2, 5, 3, 5, 2, 4, 1, 3, 0] @=> int base[];
markov.generateTransitionMatrix(base, order, range) @=> float transitionMatrix[][];

[1.14, 1.11, 1.20, 1.17, 1.20, 1.23] @=> float ratios[];
base @=> int inputChain[];

while (true) {
    for (0 => int i; i < inputChain.size(); i++) {
        q1.ratio(ratios[ inputChain[ i ] ]);
        q2.ratio(ratios[ inputChain[ i ] ]);
        100::ms => now;
    }
    markov.generateChain(base, transitionMatrix, order, range) @=> inputChain;
}
