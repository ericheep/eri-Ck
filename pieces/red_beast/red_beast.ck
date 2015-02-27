// red beast
// Eric Heep

// osc stuff
OscOut out;
("localhost", 12001) => out.dest;

// consts
2 * pi => float two_pi;
7 => int num_cols;

// long sin waves
SinOsc sin[num_cols];

// sin wave parameters
float sin_frq[num_cols];
float sin_vol[num_cols];
float sin_prev_frq[num_cols];
float phase[num_cols];
float phase_inc[num_cols];

[14, 9, 9, 7, 9, 9, 14] @=> int total_size[];
[7, 5, 5, 3, 5, 5, 7] @=> int ceiling_size[];
[7, 4, 4, 4, 4, 4, 7] @=> int wall_size[];

// sin values
float sin_val[7][0];
float big_val[7][0];
float big_check[7][0];
float circle_val[7][0];
float all_val[7][0];

// all our values
float total_width[7][0];
float total_height[7][0];

// circle vals
float circle_mod; 
float circle_offset;
0.05 => float circle_range;

// big vals
1.0 => float big_vol;
1.12 => float big_frq;
float big_amp;
float big_prev_frq;
float big_phase;
float big_phase_inc;
float high, low, width;
1.0/12.0 => width;

[-1.0, -2.0/3.0, -1.0/3.0, -1.0/6.0, 1.0/6.0, 1.0/3.0, 2.0/3.0, 1.0] @=> float big_col[];
[1.0/6.0, 1.0/6.0, 1.0/12.0, 1.0/6.0, 1.0/12.0, 1.0/6.0, 1.0/6.0] @=> float big_ratio[];

// converts -1.0 to 1.0 to 0.0 to 1.0
for (int i; i < big_col.size(); i++) {
    (big_col[i] + 1.0) * 0.5 => big_col[i];
}

for (int i; i < total_size.size(); i++) {
    total_size[i] => sin_val[i].size => circle_val[i].size;
    total_size[i] => big_val[i].size => big_check[i].size => all_val[i].size;
    total_size[i] => total_width[i].size => total_height[i].size;
}

// addresses for the ceiling squares
["/cw0", "/cw1", "/cw2", "/cw3", "/cw4", "/cw5", "/cw6"] @=> string cw_addr[];
["/ch0", "/ch1", "/ch2", "/ch3", "/ch4", "/ch5", "/ch6"] @=> string ch_addr[];
// addresses for the wall squares
["/ww0", "/ww1", "/ww2", "/ww3", "/ww4", "/ww5", "/ww6"] @=> string ww_addr[];
["/wh0", "/wh1", "/wh2", "/wh3", "/wh4", "/wh5", "/wh6"] @=> string wh_addr[];

// test functions
spork ~changeFrq();
spork ~changeVol();
spork ~circle();

fun void changeVol() {
    while (true) {
        for (int i; i < num_cols; i++) {
            (Math.sin(now/minute) + 1.0) * 0.5 => sin_vol[i];
        }
        10::ms => now;
    }
}

fun void changeFrq() {
    //while (true) {
        for (int i; i < num_cols; i++) {
            //Math.random2f(20.0, 2000.0)=> sin_frq[i];
            (i * 0.01) + 1 => sin_frq[i];
        }
        5::second => now;
    //}
}

fun void circle() {
    while (true) {
        (circle_mod + 0.001) % 1.0 => circle_mod;
        35::ms => now;
    }
}

// zeros out arrs per loop
fun void zeroArr(float arr[]) {
    for (int i; i < arr.size(); i++) {
        0 => arr[i];
    }
}

// multiple sin stuff
fun void sinCalc(int idx, float frq, float vol, float arr[]) {
    // moves array around to next spot
    for (arr.cap() - 2 => int i; i >= 0; i--) {
        arr[i] => arr[i + 1];
    }
    
    // only calculates when needed
    if (frq != sin_prev_frq[idx]) {
        frq/30.0 * two_pi => phase_inc[idx];
        frq => sin_prev_frq[idx];
    }

    // adds incrment to phase and wraps
    phase_inc[idx] +=> phase[idx];
    if (phase[idx] > two_pi) {
        two_pi -=> phase[idx];
    }
    
    // maps data into 0.0 to 1.0 values
    (Math.sin(phase[idx]) + 1) * 0.5 * vol => arr[0];

}

// circle stuff 
fun void circleCalc(float arr[]) {
    for (int i; i < arr.size(); i++) {   
        i/(arr.size() $ float) * circle_range => circle_offset;
        if (circle_mod > circle_offset && circle_mod < circle_offset + circle_range) {
            (circle_mod - circle_offset)/(circle_range/2.0) => arr[i];

            if (arr[i] > 1.0) {
                1.0 - (circle_mod - circle_offset)/(circle_range/2.0) % 1.0 => arr[i];
            }
        }
        else {
            0.0 => arr[i];
        }
    }
}

// single big sin stuff
fun void bigCalc(float arr[], float check[], float vol, float frq, int idx) {
    // moves array around to next spot
    for (arr.cap() - 2 => int i; i >= 0; i--) {
        arr[i] => arr[i + 1];
    }

    if (idx == 0) {
        // only calculates when needed
        if (frq != big_prev_frq) {
            frq/30.0 * two_pi => big_phase_inc;
            frq => big_prev_frq;
        }

        // adds incrment to phase and wraps
        big_phase_inc +=> big_phase;
        if (big_phase > two_pi) {
            two_pi -=> big_phase;
        }
    }

    // maps data into 0.0 to 1.0 values
    (Math.sin(big_phase) * vol + 1.0) * 0.5 * (1.0 - width * 2) + width  => big_amp;

    big_amp - width => low;
    big_amp + width => high;
    if (low >= big_col[idx] && low < big_col[idx + 1]) {  
        (low - big_col[idx])/big_ratio[idx] => arr[0]; 
    }
    else if (high > big_col[idx] && high <= big_col[idx + 1]) {  
        1.0 + (high - big_col[idx])/big_ratio[idx] => arr[0]; 
    }
    else if (low < big_col[idx] && high > big_col[idx + 1]) {
        0.00000001 => arr[0]; 
    }
    else {
        0.0 => arr[0];
    }
}

fun void allCalc(float arr[]) {
    // moves array around to next spot
    for (arr.cap() - 2 => int i; i >= 0; i--) {
        arr[i] => arr[i + 1];
    }
    1.0 => arr[0];
}

fun void combineVals(float arr[], float sin_arr[], float circle_arr[], float big_arr[], float all_arr[]) {
    for (int i; i < arr.size(); i++) {
        if (circle_arr[i] <= 0.1) {
            arr[i] + sin_arr[i] => arr[i];
        }
        if (circle_arr[i] > 0.1 && circle_arr[i] <= 1.0) {
            circle_arr[i] + 1.0 => arr[i];
        }
        if (big_arr[i] > 0.0) {
            big_arr[i] + 2.0 => arr[i];
        }
        if (all_arr[i] > 0.0) {
            all_arr[i] => arr[i];
        }
    }
}

fun void oscSend(string ceiling, string wall, float arr[], int col) {
    // to the ceiling
    ("localhost", 12001) => out.dest;

    out.start(ceiling);
    for (int i; i < ceiling_size[col]; i++) {
        out.add(arr[i]);
    }
    out.send();
    
    // to the wall
    ("localhost", 12002) => out.dest;

    out.start(wall);
    for (int i; i < wall_size[col]; i++) {
        out.add(arr[i + ceiling_size[col]]);
    }
    out.send();
}

// updates at framerate
while (true) {
    // zeros contents of the array
    for (int i; i < num_cols; i++) {
        zeroArr(total_width[i]);
        zeroArr(total_height[i]);
    }
    // calculation functions 
    for (int i; i < num_cols; i++) {
        //sinCalc(i, sin_frq[i], sin_vol[i], sin_val[i]);
        circleCalc(circle_val[i]);
        //bigCalc(big_val[i], big_check[i], big_vol, big_frq, i);
        //allCalc(all_val[i]);
    }
    // heirachly combines values for sending
    for (int i; i < num_cols; i++) {
        combineVals(total_width[i], sin_val[i], circle_val[i], big_val[i], all_val[i]);
        combineVals(total_height[i], sin_val[i], circle_val[i], big_val[i], all_val[i]);
    }
    // sends osc
    for (int i; i < num_cols; i++) {
        oscSend(cw_addr[i], ww_addr[i], total_width[i], i);
        oscSend(ch_addr[i], wh_addr[i], total_height[i], i);
    }
    1::second/30.0 => now;
}
