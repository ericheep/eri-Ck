HandshakeID talk;
2.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
2.5::second => now;

Puck p;
p.init(0);

16 => int NUM_LEDS;

int inc;

while (true) {
    inc++;
    for (0 => int i; i < NUM_LEDS; i++) {
        p.send(i, inc % 1024, 255, 220);

    }
    100::ms => now;
}
