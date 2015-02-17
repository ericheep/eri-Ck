// Quneo.ck
// Dexter Shepherd and Eric Heep
// CalArts Music Tech // MTIID4LIFE
// class for communicating with ChucK and a Quneo

// configured for Quneo configuration mode 4
// press the small circle in the top left and 
// select the fourth pad to activate mode 4

public class Quneo { 

    16 => int num_pads;
    10 => int num_sliders;
    13 => int num_buttons;
    
    // arrays for velocity and three axes
    int pad_v[num_pads];
    int pad_z[num_pads];
    int pad_x[num_pads];
    int pad_y[num_pads];

    // arrays for sliders
    int slider[10];

    // arrays for buttons
    int button[13];

    // special buttons
    int play, stop, diamond, fader;
    

    [23, 26, 29, 32, 35, 38, 41, 44,
     47, 50, 53, 56, 59, 62, 65, 68] @=> int z[];

    [24, 27, 30, 33, 36, 39, 42, 45,
     48, 51, 54, 57, 60, 63, 66, 69] @=> int x[];

    [25, 28, 31, 34, 37, 40, 43, 46,
     49, 52, 55, 58, 61, 64, 67, 70] @=> int y[];

    
    // midi setup
    int port;
    MidiIn min[10];
    MidiOut mout[10];
    MidiMsg msgIn;
    MidiMsg msgOut;
    
    for (int i; i < min.cap(); i++) {
        // no print err
        min[i].printerr(0);
        
        // open the device
        if (min[i].open(i)) {
            if (min[i].name() == "QUNEO") {
                i => port;
                <<< "Connected to", min[port].name(), "" >>>;
                mout[i].open(i);
            }
        }
        else break;
    } 
    
    spork ~ update();

    // input
    fun void update() {
        while (true) {
            // waits on midi events
            min[port] => now;
            while (min[port].recv(msgIn)) {
                getValues(msgIn.data1, msgIn.data2, msgIn.data3);
                // 23 is z, 24 is x, 25 is y
                // <<< msgIn.data1, msgIn.data2, msgIn.data3 >>>;
            }
        }
    }
    
    // convert values
    fun void getValues(int data1, int data2, int data3){
        if((data1 == 144)||(data1 == 128)){
            for (int i; i < num_pads; i++){
                data3 => pad_v[i];
            }
        }
        if (data1 == 176) {
            for (int i; i < num_pads; i++) {
                if(data2 == x[i]){
                    data3 => pad_x[i];
                }
                if(data2 == y[i]){
                    data3 => pad_y[i];
                }
                if(data2 == z[i]){
                    data3 => pad_z[i];
                }
            }

            if (data2 == 10) {
                data3 => fader;
            }
            for (int i; i < 10; i++) {
                if (data2 == i) {
                    data3 => slider[i];
                }
            }
            for (int i; i < 13; i++) {
                if (data2 == i + 71) {
                    data3 => button[i];
                }
            }
            if (data2 == 84) {
                data3 => diamond;
            }
            if (data2 == 85) {
                data3 => stop;
            }
            if (data2 == 86) {
                data3 => play;
            }
        }
        
        /*
        for (int i; i < 16; i++){
            if(data2 == i + 16){
                data3 => padZ[i];
            }
            else if(data2 == i + 32){
                data3 => padX[i];
            }
            else if(data2 == i + 48) {
                data3 => padY[i];
            }
            else if(data2 == i + 64) {
                data3 => slider[i];
            }
        }
        */
    }

    fun int pad(int idx) {
        return pad_v[idx];
    }
    
    fun int pad(int idx, string mode) {
        if (mode == "v") {
            return pad_v[idx];
        }
        if (mode == "x") {
            return pad_x[idx];
        }
        if (mode == "y") {
            return pad_y[idx];
        }
        if (mode == "z") {
            return pad_z[idx];
        }
    }
    
    fun void led(int type, int num, int vel) {
        type => msgOut.data1;
        num => msgOut.data2;
        vel => msgOut.data3;
        mout[port].send(msgOut);
    }
    
    // output Functions
    /*
    fun void padLEDOn(int padNumber, int color, int brightness){
        144 => msgOut.data1;
        if(color == 0){
            padLEDGreen[padNumber] => msgOut.data2;
        }
        else if(color == 1){
            padLEDRed[padNumber] => msgOut.data2;
        }
        brightness => msgOut.data3;
        
        mout[port].send(msgOut);
    }
    
    fun void padLEDOff(int padNumber, int color){
        128 => msgOut.data1;
        
        if(color == 0){
            padLEDGreen[padNumber] => msgOut.data2;
        }
        else if(color == 1){
            padLEDRed[padNumber] => msgOut.data2;
        }
        
        0 => msgOut.data3;
        
        mout[port].send(msgOut);
    }
    */
}

Quneo q;

while (true) {
    <<< q.pad(0, "v") >>>;
    100::ms => now;
}
