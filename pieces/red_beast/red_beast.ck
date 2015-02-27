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

// single sin
SingleSin s_sin;
s_sin.init(num_cols);
float single_sin[num_cols][0];

// array allocation
for (int i; i < num_cols; i++) {
    total_size[i] => multi_sin[i].size;
    total_size[i] => single_sin[i].size;
}

// test loop
for (int i; i < num_cols; i++) {
    m_sin.freq(i, Math.random2f(1.1, 2.1));
    m_sin.vol(i, Math.random2f(0.5, 1.0));
    s_sin.freq(Math.random2f(1.1, 2.1));
    s_sin.vol(Math.random2f(0.5, 1.0));
}

// consts
2 * pi => float two_pi;

float circle_val[7][0];
float all_val[7][0];

// all our values
float total_width[7][0];
float total_height[7][0];

// circle vals
float circle_mod; 
float circle_offset;
0.05 => float circle_range;

for (int i; i < total_size.size(); i++) {
    total_size[i] => circle_val[i].size;
    total_size[i] => all_val[i].size;
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
        //allCalc(all_val[i]);
    }

    m_sin.calc(multi_sin) @=> multi_sin;
    s_sin.calc(single_sin) @=> single_sin;

    for (int i; i < num_cols; i++) {
        combineVals(total_width[i], multi_sin[i], circle_val[i], single_sin[i], all_val[i]);
        combineVals(total_height[i], multi_sin[i], circle_val[i], single_sin[i], all_val[i]);
    }

    // sends osc
    out.send("width", total_width);
    out.send("height", total_height);
    1::second/30.0 => now;
}
