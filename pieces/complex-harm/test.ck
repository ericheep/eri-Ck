SinOsc nois;
nois.gain(0.2);

4 => int NUM_CHAN;

while (true) {
    for (0 => int i; i < NUM_CHAN; i++) {
        nois => dac.chan(i);
        1000::ms => now;
        nois =< dac.chan(i);
    }
}
