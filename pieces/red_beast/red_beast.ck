// red beast
// Eric Heep

// beast osc setup
BeastOsc out;
out.setDest("ceiling", "localhost", 12001);
out.setDest("wall", "localhost", 12002);

// beast osc row/column setup
[14, 9, 9, 7, 9, 9, 14] @=> int total_size[];
out.setCols(total_size.size());
out.setRows("ceiling", [7, 5, 5, 3, 5, 5, 7]);
out.setRows("wall", [7, 4, 4, 4, 4, 4, 7]);

// number of columns
7 => int num_cols;

// multi sin
MultiSin m_sin;
m_sin.init(num_cols);
float multi_sin[num_cols][0];

for (int i; i < num_cols; i++) {
    total_size[i] => multi_sin[i].size;
}

// test loop
for (int i; i < num_cols; i++) {
    m_sin.freq(i, Math.random2f(1.1, 2.1));
    m_sin.gain(i, Math.random2f(0.5, 1.0));
}

// consts
2 * pi => float two_pi;

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
    total_size[i] => circle_val[i].size;
    total_size[i] => big_val[i].size => big_check[i].size => all_val[i].size;
    total_size[i] => total_width[i].size => total_height[i].size;
}

// test functions
spork ~circle();

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

// updates at framerate
while (true) {
    // zeros contents of the array
    for (int i; i < num_cols; i++) {
        zeroArr(total_width[i]);
        zeroArr(total_height[i]);
    }

    // calculation functions 
    for (int i; i < num_cols; i++) {
        //circleCalc(circle_val[i]);
        //bigCalc(big_val[i], big_check[i], big_vol, big_frq, i);
        //allCalc(all_val[i]);
    }

    m_sin.calc(multi_sin) @=> multi_sin;

    for (int i; i < num_cols; i++) {
        combineVals(total_width[i], multi_sin[i], circle_val[i], big_val[i], all_val[i]);
        combineVals(total_height[i], multi_sin[i], circle_val[i], big_val[i], all_val[i]);
    }

    // sends osc
    out.send("width", total_width);
    out.send("height", total_height);
    1::second/30.0 => now;
}
