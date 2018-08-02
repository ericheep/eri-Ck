// RandomPulse.ck
// communication

public class RandomPulse {

    WinFuncEnv win => blackhole;
    win.setBlackmanHarris();

    false => int isPulsing;

    int activeLEDs[0];
    0 => int NUM_PUCKS;
    0 => int NUM_TOTAL_LEDS;

    fun void init(int numPucks) {
        numPucks => NUM_PUCKS;
        numPucks * 16 => NUM_TOTAL_LEDS;
    }

    fun void setActiveLEDs(int numActiveLEDs) {
        activeLEDs.clear();
        activeLEDs.size(0);

        for (0 => int i; i < numActiveLEDs; i++) {
            activeLEDs << Math.random2(0, NUM_TOTAL_LEDS - 1);
        }
    }

    fun void updateColors(float vals[][], float hues[][], float max, float hue) {
        for (0 => int i; i < activeLEDs.size(); i++) {
            activeLEDs[i] % 16 => int whichLED;
            activeLEDs[i] / 16 => int whichPuck;

            win.windowValue() * max +=> vals[whichPuck][whichLED];
            hue => hues[whichPuck][whichLED];
        }
    }

    fun void pulse (dur env, int numActiveLEDs, float vals[][], float hues[][], float max, float hue) {
        if (!isPulsing) {
            setActiveLEDs(numActiveLEDs);
            spork ~ pulsing(env, env);
        }
        updateColors(vals, hues, max, hue);
    }

    fun void pulsing(dur attack, dur release) {
        true => isPulsing;

        win.attackTime(attack);
        win.releaseTime(release);

        win.keyOn();
        attack => now;

        win.keyOff();
        release => now;

        false => isPulsing;
    }
}
