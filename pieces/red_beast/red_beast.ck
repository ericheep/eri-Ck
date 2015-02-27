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

// orbit sin
OrbitSin o_sin;
o_sin.init(num_cols);
float orbit_sin[num_cols][0];

// array allocation
for (int i; i < num_cols; i++) {
    total_size[i] => multi_sin[i].size;
    total_size[i] => single_sin[i].size;
    total_size[i] => orbit_sin[i].size;
}

// test loop
for (int i; i < num_cols; i++) {
    m_sin.freq(i, Math.random2f(1.1, 2.1));
    m_sin.vol(i, Math.random2f(0.5, 1.0));
}

s_sin.freq(Math.random2f(1.1, 8.1));
s_sin.vol(Math.random2f(0.5, 1.0));
o_sin.range(0.2);
o_sin.offset(0.5);
o_sin.speed(0.01);

float all_val[7][0];

// all our values
float total_width[7][0];
float total_height[7][0];

for (int i; i < total_size.size(); i++) {
    total_size[i] => all_val[i].size;
    total_size[i] => total_width[i].size => total_height[i].size;
}

// resets arrays
fun void zeroArr(float arr[][]) {
    for (int i; i < num_cols; i++) {
        for (int j; j < arr[i].size(); j++) {
            0 => arr[i][j];
        }
    }
}

// highlights every square
fun void allArr(float arr[][]) {
    for (int i; i < num_cols; i++) {
        for (total_size[i] - 2 => int j; j >= 0; j--) {
            arr[i][j] => arr[i][j + 1];
        }
        1.0 => arr[i][0];
    }
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
    zeroArr(total_width);
    zeroArr(total_height);

    m_sin.calc(multi_sin) @=> multi_sin;
    s_sin.calc(single_sin) @=> single_sin;
    o_sin.calc(orbit_sin) @=> orbit_sin;
    allArr(all_val);

    for (int i; i < num_cols; i++) {
        combineVals(total_width[i], multi_sin[i], orbit_sin[i], single_sin[i], all_val[i]);
        combineVals(total_height[i], multi_sin[i], orbit_sin[i], single_sin[i], all_val[i]);
    }

    // sends osc
    out.send("width", total_width);
    out.send("height", total_height);
    1::second/30.0 => now;
}
