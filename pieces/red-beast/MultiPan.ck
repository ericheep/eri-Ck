public class MultiPan extends Chubgraph {
    4 => int numCh;
    Gain chGn[numCh];

    int ch;
    float vl;
    numCh/2.0 => float mid;

    for (int i; i < numCh; i++) {
        inlet => chGn[i] => dac.chan(i);
    }

    fun void vol(float v) {
        v => vl;
        for (int i; i < numCh; i++) {
            chGn[i].gain(v);
        }
    }
    
    fun void pan(float pos) {
        if (pos >= -1.0 && pos <= 1.0) {
            // rescales pos to a value between 0 and ch (or ch - 1)
            (pos + 1.0) * mid + 0.5 => pos;

            // separates pos float from channel int
            pos $ int => ch;
            pos - ch => pos; 

            // clearing gain
            for (int i; i < numCh; i++) {
                chGn[i].gain(0.0);
            }

            if (ch == 0) {
                chGn[numCh - 1].gain((1.0 - pos) * vl);
                chGn[ch].gain(pos * vl);
            }     
            else if (ch == numCh) {
                chGn[ch - 1].gain((1.0 - pos) * vl);
                chGn[0].gain(pos * vl);
            }
            else {
                chGn[ch - 1].gain((1.0 - pos) * vl);
                chGn[ch].gain(pos * vl);
            }
        }
    }
}
