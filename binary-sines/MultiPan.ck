public class MultiPan extends Chubgraph {
    5 => int numCh;
    Gain chGn[numCh];

    for (int i; i < numCh; i++) {
        inlet => chGn[i] => dac.chan(i);
    }

    fun void pan(float pos) {
        float mid;

        // different behavior for an odd or even number of channels
        if (numCh % 2 == 1) {
            (numCh - 1)/2.0 => mid;
        }
        else {
            numCh/2.0 => mid;
        }

        // rescales pos to a value between 0 and ch (or ch - 1)
        (pos + 1.0) * mid => pos;

        // separates pos float from channel int
        pos $ int => int ch;
        pos - ch => pos; 

        // clearing gain
        for (int i; i < numCh; i++) {
            chGn[i].gain(0.0);
        }

        if (pos > 0.0) {
            chGn[ch].gain(1.0 - pos);
            chGn[ch + 1].gain(pos);
        }
        else {
            chGn[ch].gain(1.0);
        }
    }
}
