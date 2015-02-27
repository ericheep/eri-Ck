// Eric Heep
// red_beast, for Manuel Lima's 2nd Year DMA Recital "Red Light Piano"
// MTIID4LIFE

public class Utility {
   
    int num_cols;
    int num_rows[0];

    fun void init(int total[]) {
        total.size() => num_cols => num_rows.size;
        for (int i; i < num_cols; i++) {
            total[i] => num_rows[i];
        }
    }

    // fills all the squares, used mainly for initial projection mapping
    fun float[][] all(float val[][]) {
        for (int i; i < num_cols; i++) {
            for (int j; j < num_rows[i]; j++) {
                1.0 => val[i][j];
            }
        }
        return val;
    }
    
    // resets arrays each frame 
    fun float[][] zero(float val[][]) {
        for (int i; i < num_cols; i++) {
            for (int j; j < num_rows[i]; j++) {
                0 => val[i][j];
            }
        }
        return val;
    }

    // decides a heirarchy for the different arrays
    fun float[][] order(float val[][], float multi[][], float orbit[][], float single[][]) {
        for (int i; i < num_cols; i++) {
            for (int j; j < num_rows[i]; j++) {
                if (val[i][j] <= 0.1) {
                    val[i][j] + multi[i][j] => val[i][j];
                }
                if (orbit[i][j] > 0.1 && orbit[i][j] <= 1.0) {
                    orbit[i][j] + 1.0 => val[i][j];
                }
                if (single[i][j] > 0.0) {
                    single[i][j] + 2.0 => val[i][j];
                }
            }
        }

        return val;
    }
}
