public class BeastOsc {

    OscOut ceilingOut;
    OscOut wallOut;

    // addresses for the ceiling squares
    [["/cw0", "/cw1", "/cw2", "/cw3", "/cw4", "/cw5", "/cw6"],
     ["/ch0", "/ch1", "/ch2", "/ch3", "/ch4", "/ch5", "/ch6"]] @=> string ceilingAddr[][];;
    // addresses for the wall squares
    [["/ww0", "/ww1", "/ww2", "/ww3", "/ww4", "/ww5", "/ww6"],
     ["/wh0", "/wh1", "/wh2", "/wh3", "/wh4", "/wh5", "/wh6"]] @=> string wallAddr[][];

    ceilingAddr[0] @=> ceilingAddr["width"];    
    wallAddr[0] @=> wallAddr["width"];    
    ceilingAddr[1] @=> ceilingAddr["height"];    
    wallAddr[1] @=> wallAddr["height"];    

    int ceiling_size[];
    int wall_size[];

    int num_cols;

    fun void setCols(int c) {
        c => num_cols;
    }

    fun void setRows(string location, int rows[]) {
        if (location == "ceiling") {
            rows @=> ceiling_size;
        }
        if (location == "wall") {
            rows @=> wall_size;
        }
    }

    fun void setDest(string location, string ip, int port) {
        if (location == "ceiling") {
            (ip, port) => ceilingOut.dest;
        }
        if (location == "wall") {
            (ip, port) => wallOut.dest;
        }
    }

    fun void send(string type, float val[][]) {

        for (int i; i < num_cols; i++) {
            // to the ceiling
            ceilingOut.start(ceilingAddr[type][i]);
            for (int j; j < ceiling_size[i]; j++) {
                ceilingOut.add(val[i][j]);
            }
            ceilingOut.send();
            
            // to the wall
            wallOut.start(wallAddr[type][i]);
            for (int j; j < wall_size[i]; j++) {
                wallOut.add(val[i][j + ceiling_size[i]]);
            }
            wallOut.send();
        }
    }
}
