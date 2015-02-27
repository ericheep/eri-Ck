// red beast
// Eric Heep

// beast osc setup
BeastOsc out;
out.setDest("ceiling", "localhost", 12001);
out.setDest("wall", "localhost", 12002);

// beast osc row/column setup
[14, 9, 9, 7, 9, 9, 14] @=> int num_rows[];
out.setCols(num_rows.size());
out.setRows("ceiling", [7, 5, 5, 3, 5, 5, 7]);
out.setRows("wall", [7, 4, 4, 4, 4, 4, 7]);

// number of columns
7 => int num_cols;

// utility array class
Utility u;
u.init(num_rows);

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
    num_rows[i] => multi_sin[i].size;
    num_rows[i] => single_sin[i].size;
    num_rows[i] => orbit_sin[i].size;
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

// all our values
float total_width[7][0];
float total_height[7][0];

for (int i; i < num_rows.size(); i++) {
    num_rows[i] => total_width[i].size => total_height[i].size;
}

// updates at framerate
while (true) {
    u.zero(total_width) @=> total_width;
    u.zero(total_height) @=> total_height;

    m_sin.calc(multi_sin) @=> multi_sin;
    //s_sin.calc(single_sin) @=> single_sin;
    //o_sin.calc(orbit_sin) @=> orbit_sin;

    u.order(total_width, multi_sin, orbit_sin, single_sin) @=> total_width;
    u.order(total_height, multi_sin, orbit_sin, single_sin) @=> total_height;

    //u.all(total_width) @=> total_width;
    //u.all(total_height) @=> total_height;
    
    // sends osc
    out.send("width", total_width);
    out.send("height", total_height);
    1::second/30.0 => now;
}
