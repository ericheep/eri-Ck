// red-beast

// Eric Heep
// for Manuel Lima's 2nd Year DMA Recital "Red Light Piano"
// MTIID4LIFE

public class OrbitSin extends Chubgraph{

    int num_cols;
    float rnge, offst, spd, mod;

    fun void init(int n) {
        n => num_cols;
    }

    fun void range(float r) {
        r => rnge;
    }

    fun void offset(float o) {
        o => offst;
    }

    fun void speed(float s) {
        s => spd;
    }

    // multiple sin stuff
    fun float[][] calc(float val[][]) {
        (mod + spd) % 1.0 => mod;
        for (int i; i < num_cols; i++) {
            for (int j; j < val[i].size(); j++) {   
                j/(val[i].size() $ float) * rnge => offst;
                if (mod > offst && mod < offst + rnge) {
                    (mod - offst)/(rnge/2.0) => val[i][j];
                    if (val[i][j] > 1.0) {
                        1.0 - (mod - offst)/(rnge/2.0) % 1.0 => val[i][j];
                    }
                }
                else {
                    0.0 => val[i][j];
                }
            }
        }

        return val;
    }
}

