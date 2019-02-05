// ES8Osc.ck

// OSC receiver to receive commands from
// the web server.

public class ES8Osc {
    OscIn osc;
    osc.port(12345);
    osc.listenAll();

    OscMsg msg;

    ES8 es8;

    // init
    es8.loadConfig();
    es8.calibratePitch(69, 5.0);
    es8.calibrateFrequency(440, 5.0);

    8 => int NUM_OUTPUTS;
    Step s[NUM_OUTPUTS];

    44100 => int samplesLength;
    float samples[samplesLength];

    for (0 => int i; i < NUM_OUTPUTS; i++) {
        s[i] => dac.chan(i);
        s[i].next(es8.volt(0, 0.0));
    }

    public void loop() {
        while (true) {
            for (0 => int i; i < samplesLength; i++) {
                s[0].next(samples[i]);
                samp => now;
            }
        }
    }

    public void listen() {
        while (true) {
            osc => now;

            while (osc.recv(msg)) {
                msg.getInt(0) => int channel;
                msg.getFloat(0) => float val;

                <<< msg.address, channel, val >>>;

                if (msg.address == "/freq") {
                    s[channel].next(es8.freq(channel, val));
                }
                if (msg.address == "/volt") {
                    s[channel].next(es8.volt(channel, val));
                }
                if (msg.address == "/pitch") {
                    s[channel].next(es8.pitch(channel, val));
                }
                if (msg.address == "/sequencer") {
                    msg.getInt(1) => int index;
                    es8.freq(channel, val) => samples[index];
                }
            }
        }
    }
}
