// Pulse.ck
// communication

public class Pulse {

    WinFuncEnv win => blackhole;
    win.setBlackmanHarris();

    false => int isPulsing;
    0 => int numLeds;

    fun void init(int n) {
        n => numLeds;
    }

    fun float[] updateColors(float val[], float max) {
        for (0 => int i; i < numLeds; i++) {
            win.windowValue() * max => val[i];
        }
        return val;
    }

    fun void pulse (dur attack, dur release, float val[], float max) {
        if (!isPulsing) {
            spork ~ pulsing(attack, release);
        }

        updateColors(val, max);
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
