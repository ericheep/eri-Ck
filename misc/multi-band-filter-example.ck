// multi-band-filter-example.ck

// quick and dirty example of
// equally spaced filter bands

// constants
5 => int NUM_FILTERS;
0.0 => float LOW;
10000.0 => float HIGH;

CNoise nois;

LPF lps[NUM_FILTERS];
HPF hps[NUM_FILTERS];

(HIGH - LOW)/(NUM_FILTERS) => float bandWidth;

for (0 => int i; i < NUM_FILTERS; i++) {
    // sound chain
    nois => lps[i] => hps[i] => dac;

    // set equal-spaced filter bands
    // note that this is linear, for perceptual effects
    // you would want a logarithmically spaced filter bands
    // I'd recommend looking into Mel bands or Bark bands
    lps[i].freq(i * bandWidth);
    hps[i].freq((i + 1) * bandWidth);
}

// small example that turns off certain bands at
// random just to hear the filters do their magic
while (true) {
    Math.random2(0, NUM_FILTERS - 1) => int index;

    lps[index].gain(0.0);
    hps[index].gain(0.0);

    0.1::second => now;

    lps[index].gain(1.0);
    hps[index].gain(1.0);
}


