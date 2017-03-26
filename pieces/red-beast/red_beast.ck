// red-beast

// Eric Heep
// for Manuel Lima's 2nd Year DMA Recital "Red Light Piano"
// MTIID4LIFE

// beast osc setup
BeastOsc out;
out.setDest("ceiling", "10.0.0.3", 12001);
//out.setDest("ceiling", "localhost", 12001);
out.setDest("wall", "localhost", 12002);

// beast osc row/column setup
[14, 9, 9, 7, 9, 9, 14] @=> int num_rows[];
out.setCols(num_rows.size());
out.setRows("ceiling", [7, 5, 5, 3, 5, 5, 7]);
out.setRows("wall",    [7, 4, 4, 4, 4, 4, 7]);

NanoKontrol n;
Quneo q;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ visuals setup
// number of columns
7 => int num_cols;
int off;

// utility array class
Utility u;
u.init(num_rows);

// zero
float zero[num_cols][0];

// blink sin
BlinkSin b_sin;
float blink_sin[num_cols][0];

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

// all our values
float total_width[num_cols][0];
float total_height[num_cols][0];

// array allocation
for (int i; i < num_cols; i++) {
    num_rows[i] => zero.size;
    num_rows[i] => blink_sin[i].size;
    num_rows[i] => multi_sin[i].size;
    num_rows[i] => single_sin[i].size;
    num_rows[i] => orbit_sin[i].size;
    num_rows[i] => total_width[i].size;
    num_rows[i] => total_height[i].size;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ controls setup

int mode, mode_latch;

// updates at framerate (30/fps)
fun void visuals() {
    u.zero(total_width) @=> zero;

    while (true) {
        u.zero(total_width) @=> total_width;
        u.zero(total_height) @=> total_height;

        m_sin.calc(multi_sin) @=> multi_sin;
        s_sin.calc(single_sin) @=> single_sin;

        if (off == 0) {
            o_sin.calc(orbit_sin) @=> orbit_sin;
        }
        
        u.order(total_width, blink_sin, multi_sin, orbit_sin, single_sin) @=> total_width;
        u.order(total_height, blink_sin, multi_sin, orbit_sin, single_sin) @=> total_height;

        // sets every square to red, mainly for mapping
        //u.all(total_width) @=> total_width;
        //u.all(total_height) @=> total_height;
        
        // sends osc
        out.send("width", total_width);
        out.send("height", total_height);
        1::second/30.0 => now;
    }
}

fun void modeFeedback(int val) {
    repeat(3) {
        for (int i; i < val + 1; i++) {
            q.pad(0 + i, "r", 30);
            q.pad(4 + i, "r", 30);
            q.pad(8 + i, "r", 30);
            q.pad(12 + i, "r", 30);
        }
        50::ms => now;
        for (int i; i < val + 1; i++) {
            q.pad(0 + i, "r", 0);
            q.pad(4 + i, "r", 0);
            q.pad(8 + i, "r", 0);
            q.pad(12 + i, "r", 0);
        }
        50::ms => now;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~ input
Gain input[3];
adc.chan(0) => input[0];
adc.chan(1) => input[1];
adc.chan(2) => input[2];

for (int i; i < 3; i++) {
    input[i].gain(0.0);
}

int rewind_latch, play_latch, fastforward_latch;

fun void inputSwitch() {
    if (n.rewind > 0 && rewind_latch == 0) {
        input[0].gain(1.0);
        input[1].gain(0.0);
        input[2].gain(0.0);
        1 => rewind_latch;
    }
    if (n.rewind == 0 && rewind_latch == 1) {
        0 => rewind_latch;

    }
    if (n.play > 0 && play_latch == 0) {
        input[0].gain(0.0);
        input[1].gain(1.0);
        input[2].gain(0.0);
        1 => play_latch;
    }
    if (n.play == 0 && play_latch == 1) {
        0 => play_latch;
    }
    if (n.fastforward > 0 && fastforward_latch == 0) {
        input[0].gain(0.0);
        input[1].gain(0.0);
        input[2].gain(1.0);
        1 => fastforward_latch;
    }
    if (n.fastforward == 0 && fastforward_latch == 1) {
        0 => fastforward_latch;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~ sineMode setup 
0.25 => float sin_adjust;

SinOsc sine_bass => dac.chan(4); 
sine_bass => dac.chan(5);
sine_bass.gain(0.0);
sine_bass.freq(55);
b_sin.gain(0.0);
float sine_bass_gain;
int blinkPhrase_vol;
for (int i; i < 4; i++) {
    b_sin => dac.chan(i);
}


BlinkSin bp[16];
int bp_latch[16];

for (int i; i < 16; i++) {
    bp[i] => dac.chan(i % 4);
    bp[i].freq(Math.random2(2470, 2530));
    bp[i].attck(10::ms + i * 3::ms);
    bp[i].rlease(55::ms + i * 3::ms);
    bp[i].size(num_cols, num_rows);
}

int sine_bot[8];
int sine_knob[8];
int sine_latch[8];
int sine_slider[8];

spork ~ sineSmooth();

fun void sineSmooth() {
    float current_gain;
    while (true) {
        if (current_gain < sine_bass_gain) {
            0.0001 +=> current_gain; 
            sine_bass.gain(current_gain);

        }
        if (current_gain > sine_bass_gain) {
            0.0001 -=> current_gain; 
            sine_bass.gain(current_gain);
        }
        0.5::ms => now;
    }
}

fun void blinkPhrases() {
    if (q.fader_x != blinkPhrase_vol) {
        q.fader_x => blinkPhrase_vol;
        for (int i; i < 16; i++) {
            blinkPhrase_vol/127.0 => bp[i].gain;
        }
    }
    for (int i; i < 16; i++) {
        if (q.pad(i) > 0 && bp_latch[i] == 0) {
            bp[i].blinkPhrase(1); 
            1 => bp_latch[i];
        }
        if (q.pad(i) == 0 && bp_latch[i] == 1) {
            bp[i].blinkPhrase(0); 
            0 => bp_latch[i];
            u.zero(blink_sin) @=> blink_sin;
        }
        if (bp_latch[i] == 1) {
            Math.random2f(0.0, 1.0) => blink_sin[bp[i].x1][bp[i].y1];
        }
    }
}

fun void sineMode() {
    if (n.slider[0] != sine_slider[0]) {
        n.slider[0] => sine_slider[0];
        sine_slider[0]/127.0 * 0.75 => sine_bass_gain; 
    }
    if (n.slider[1] != sine_slider[1]) {
        n.slider[1] => sine_slider[1];
        b_sin.gain(sine_slider[1]/127.0 * sin_adjust); 
    }
    if (n.bot[1] > 0 && sine_latch[1] == 0) {
        b_sin.freq(440 * 7);
        spork ~ b_sin.blink(0, 1); 
        b_sin.calc(blink_sin, num_cols, num_rows) @=> blink_sin;
        1 => sine_latch[1];
    }
    if (n.bot[1] == 0 && sine_latch[1] == 1) {
        0 => sine_latch[1];
        u.zero(blink_sin) @=> blink_sin;
    }
    if (n.slider[2] != sine_slider[2]) {
        n.slider[2] => sine_slider[2];
        b_sin.gain(sine_slider[2]/127.0 * sin_adjust); 
    }
    if (n.bot[2] > 0 && sine_latch[2] == 0) {
        b_sin.freq(440 * 5);
        spork ~ b_sin.blink(0, 1); 
        b_sin.moveBlink(blink_sin, num_cols, num_rows, 0) @=> blink_sin;
        1 => sine_latch[2];
    }
    if (n.bot[2] == 0 && sine_latch[2] == 1) {
        0 => sine_latch[2];
        u.zero(blink_sin) @=> blink_sin;
    }
    if (n.slider[3] != sine_slider[3]) {
        n.slider[3] => sine_slider[3];
        b_sin.gain(sine_slider[2]/127.0 * sin_adjust); 
    }
    if (n.bot[3] > 0 && sine_latch[3] == 0) {
        b_sin.freq(440 * 8);
        spork ~ b_sin.blink(0, 1); 
        b_sin.moveBlink(blink_sin, num_cols, num_rows, 1) @=> blink_sin;
        1 => sine_latch[3];
    }
    if (n.bot[3] == 0 && sine_latch[3] == 1) {
        0 => sine_latch[3];
        u.zero(blink_sin) @=> blink_sin;
    }
    if (n.top[4] > 0 && sine_latch[4] == 0) {
        
    }
    if (n.slider[4] != sine_slider[4]) {
        if (n.slider[4] > 0) {
            0 => off;
            o_sin.speed(n.slider[4]/127.0 * 0.05);
            o_sin.range(0.2);
            o_sin.offset(0.5);
        }
        if (n.slider[4] <= 1) {
            1 => off;
            o_sin.speed(0.0);
            o_sin.offset(0.0);
            o_sin.range(0.0);
        }
    }
   
    blinkPhrases();
}

// ~~~~~~~~~~~~~~~~~~~~~ samplingMode setup 
int sampling_top[8];
int sampling_bot[8];
int sampling_knob[8];
int sampling_latch[8];
int sampling_slider[8];

LPF lp;

3 => int num_ph;
Phonogene ph[num_ph];
MultiPan ph_mp[num_ph];

2 => int num_srt;
Sort srt[num_srt];
MultiPan srt_mp[num_srt];

3 => int num_rh;
Reich rh[num_rh];
MultiPan rh_mp[num_rh];

16 => int num_m;
Micro m[num_m];
int m_latch[num_m];
int m_lock_latch, m_lock;
int m_vol;

for (int i; i < num_ph; i++) {
    input[0] => ph[i] => ph_mp[i];
    input[1] => ph[i];
    input[2] => ph[i];
    ph[i] => dac.chan(5);
    ph[i].gain(0.0);
    ph_mp[i].gain(0.0);
}

for (int i; i < num_srt; i++) {
    input[0] => srt[i] => srt_mp[i];
    input[1] => srt[i]; 
    input[2] => srt[i];
    srt[i] => dac.chan(5);
    srt[i].gain(0.0);
    srt_mp[i].gain(0.0);
}

for (int i; i < num_rh; i++) {
    input[0] => rh[i] => rh_mp[i];
    input[1] => rh[i];
    input[2] => rh[i];
    rh[i] => dac.chan(5);
    rh[i].gain(0.0);
    rh[i].randomPos(1);
    rh[i].voices(8);
    rh[i].bi(1);
    rh[i].randomPos(1);
    rh_mp[i];
}

for (int i; i < num_m; i++) {
    input[0] => m[i] => dac.chan(i % 4);
    input[1] => m[i];
    input[2] => m[i];
    m[i].loopTime(100::ms + (i * 20::ms));
    m[i].gain(0.0);
    m[i].size(num_cols, num_rows);
}

float swell_sin;

fun void samplingPan() {
    for (int i; i < num_ph; i++) {
        ph_mp[i].pan(Math.sin(now/second + (2 * pi)/num_ph * i));
        rh_mp[i].pan(Math.sin(now/second + (2 * pi)/num_ph * i));
    }
    for (int i; i < num_srt; i++) {
        srt_mp[i].pan(Math.sin(now/second + (2 * pi)/num_srt * i));
        (Math.sin(now/second + (2 * pi)/num_srt * i) + 1.0)/2.0 => swell_sin;
    }
}

fun void samplingMode() {
    for (int i; i < num_ph; i++) {
        if (n.bot[i] > 0 && sampling_latch[i] == 0) {
            ph[i].play(0);
            ph[i].record(1);
            1 => sampling_latch[i];
        }
        if (n.bot[i] == 0 && sampling_latch[i] == 1) {
            ph[i].record(0);
            ph[i].play(1);
            0 => sampling_latch[i];
        }
        // gain
        if (n.slider[i] != sampling_slider[i]) {
            n.slider[i] => sampling_slider[i];
            ph[i].gain(sampling_slider[i]/127.0);
        }
        if (n.knob[i] != sampling_knob[i]) {
            n.knob[i] => sampling_knob[i];
            ph[i].grainSize(sampling_knob[i]/127.0);
        }
        if (n.top[i] > 0 && sampling_top[i] == 0) {
            n.top[i] => sampling_top[i];
            ph_mp[i].vol(1.0);
            1 => sampling_top[i];
        }
        if (n.top[i] == 0 && sampling_top[i] == 1) {
            n.top[i] => sampling_top[i];
            ph_mp[i].vol(0.0);
            0 => sampling_top[i];
        }
    }
    for (int i; i < num_srt; i++) {
        if (n.bot[i + num_ph] > 0 && sampling_latch[i + num_ph] == 0) {
            srt[i].play(0);
            srt[i].record(1);
            1 => sampling_latch[i + num_ph];
        }
        if (n.bot[i + num_ph] == 0 && sampling_latch[i + num_ph] == 1) {
            srt[i].record(0);
            srt[i].play(1);
            0 => sampling_latch[i + num_ph];
        }
        // gain
        if (n.slider[i + num_ph] != sampling_slider[i + num_ph]) {
            n.slider[i + num_ph] => sampling_slider[i + num_ph];
            srt[i].gain(sampling_slider[i + num_ph]/127.0);
        }
        if (n.top[i + num_ph] > 0 && sampling_top[i + num_ph] == 0) {
            n.top[i + num_ph] => sampling_top[i + num_ph];
            srt_mp[i].vol(1.0);
            1 => sampling_top[i + num_ph];
        }
        if (n.top[i + num_ph] == 0 && sampling_top[i + num_ph] == 1) {
            n.top[i + num_ph] => sampling_top[i + num_ph];
            srt_mp[i].vol(0.0);
            0 => sampling_top[i + num_ph];
        }
    }

    for (int i; i < num_rh; i++) {
        if (n.bot[i + num_ph + num_srt] > 0 && sampling_latch[i + num_ph + num_srt] == 0) {
            rh[i].play(0);
            rh[i].record(1);
            1 => sampling_latch[i + num_ph + num_srt];
        }
        if (n.bot[i + num_ph + num_srt] == 0 && sampling_latch[i + num_ph + num_srt] == 1) {
            rh[i].record(0);
            rh[i].play(1);
            0 => sampling_latch[i + num_ph + num_srt];
        }
        // gain
        if (n.slider[i + num_ph + num_srt] != sampling_slider[i + num_ph + num_srt]) {
            n.slider[i + num_ph + num_srt] => sampling_slider[i + num_ph + num_srt];
            rh[i].gain(sampling_slider[i + num_ph + num_srt]/127.0);
        }
        if (n.top[i + num_ph + num_srt] > 0 && sampling_top[i + num_ph + num_srt] == 0) {
            n.top[i + num_ph + num_srt] => sampling_top[i + num_ph + num_srt];
            rh_mp[i].vol(1.0);
            1 => sampling_top[i + num_ph + num_srt];
        }
        if (n.top[i + num_ph + num_srt] == 0 && sampling_top[i + num_ph + num_srt] == 1) {
            n.top[i + num_ph + num_srt] => sampling_top[i + num_ph + num_srt];
            rh_mp[i].vol(0.0);
            0 => sampling_top[i + num_ph + num_srt];
        }
        if (n.knob[i + num_ph + num_srt] != sampling_knob[i + num_ph + num_srt]) {
            n.knob[i + num_ph + num_srt] => sampling_knob[i + num_ph + num_srt];
            rh[i].speed(sampling_knob[i + num_ph + num_srt]/127.0);
        }
    }
    if (q.fader_x != m_vol) {
        q.fader_x => m_vol;
        for (int i; i < num_m; i++) {
            m_vol/127.0 => m[i].gain;
        }
    }
    for (int i; i < num_m; i++) {
        if (m_lock) {
            q.pad(i, "r", 127);
            if (m_latch[i]) {
                q.pad(i, "r", 0);
            }
        }
        if (m_latch[i] == 1) {
            swell_sin => blink_sin[m[i].x][m[i].y];
        }
        if (q.pad(i) > 0 && m_latch[i] == 0) {
            m[i].loop(1); 
            1 => m_latch[i];
        }
        if (m_lock == 0) {
            if (q.pad(i) == 0 && m_latch[i]) {
                m[i].loop(0);
                0 => m_latch[i];
                u.zero(blink_sin) @=> blink_sin;
            }
        }
    }
    if (q.stop() > 0 && m_lock_latch == 0) {
        (m_lock + 1) % 2 => m_lock;
        1 => m_lock_latch; 
        if (m_lock == 0) {
            for (int i; i < num_m; i++) {
                q.pad(i, "g", 0);
            }
        }
    }
    if (q.stop() == 0 && m_lock_latch) {
        0 => m_lock_latch;
    }
    /*
    if (q.pad(i) == 0 && bp_latch[i] == 1) {
            bp[i].blinkPhrase(0); 
            0 => bp_latch[i];
            u.zero(blink_sin) @=> blink_sin;
        }
        if (bp_latch[i] == 1) {
            Math.random2f(0.0, 1.0) => blink_sin[bp[i].x1][bp[i].y1];
        }
        */
    samplingPan();
}

// ~~~~~~~~~~~~~~~~~~~~~ droneMode setup 

int drone_top[8];
int drone_bot[8];
int drone_knob[8];
int drone_latch[8];
int drone_slider[8];
float drone_gain[8];

spork ~ droneSmooth();


for (int i; i < 7; i++) {
    m_sin.adjust(1.0/sin_adjust);
}

fun void droneSmooth() {
    float current_gain[8];
    while (true) {
        for (int i; i < 7; i++) {
            if (current_gain[i] < drone_gain[i]) {
                0.0001 +=> current_gain[i]; 
                m_sin.vol(i, current_gain[i]);
            }
            if (current_gain[i] > drone_gain[i]) {
                0.0001 -=> current_gain[i]; 
                m_sin.vol(i, current_gain[i]);
            }
        }
        if (current_gain[7] < drone_gain[7]) {
            0.0001 +=> current_gain[7]; 
            s_sin.vol(current_gain[7]);

        }
        if (current_gain[7] > drone_gain[7]) {
            0.0001 -=> current_gain[7]; 
            s_sin.vol(current_gain[7]);
        }
        0.5::ms => now;
    }
}

fun void droneMode() {
    for (int i; i < 7; i++) {
        if (n.top[i] > 0 && drone_top[i] == 0) {
            1 => drone_top[i];
            m_sin.active(i, 1);
        }
        if (n.top[i] == 0 && drone_top[i] == 1) {
            0 => drone_top[i];
            m_sin.active(i, 0);
        }
        if (n.knob[i] != drone_knob[i]) {
            n.knob[i] => drone_knob[i];
            m_sin.freq(i, drone_knob[i]/127.0 * 300.0 + 100);
        }
        if (n.slider[i] != drone_slider[i]) {
            n.slider[i] => drone_slider[i];
            drone_slider[i]/127.0  * sin_adjust => drone_gain[i];
        }
    }
    if (n.top[7] > 0 && drone_top[7] == 0) {
        1 => drone_top[7];
        s_sin.active(1);
    }
    if (n.top[7] == 0 && drone_top[7] == 1) {
        0 => drone_top[7];
        s_sin.active(0);
    }
    if (n.knob[7] != drone_knob[7]) {
        n.knob[7] => drone_knob[7];
        s_sin.freq(drone_knob[7]/127.0 * 27.5 + 27.5);
    }
    if (n.slider[7] != drone_slider[7]) {
        n.slider[7] => drone_slider[7];
        drone_slider[7]/127.0 * sin_adjust => drone_gain[7];
    }
}

fun void controls() {
    while (true) {
        if (n.rec > 0 && mode_latch == 0) {
            (mode + 1) % 3 => mode;
            1 => mode_latch;
            spork ~ modeFeedback(mode);
        }
        if (n.rec == 0 && mode_latch == 1) {
            0 => mode_latch;
        }
        if (mode == 0) {
            sineMode(); 
        }
        else if (mode == 1) {
            samplingMode();
        }
        else if (mode == 2) {
            droneMode();
        }
        inputSwitch();
        master();
        10::ms => now;
    }
}

int master_knob;
int master_slider;

fun void master() {
    if (n.knob[8] != master_knob) {
        lp.freq(master_knob/127.0 * 10000 + 20);
    }
    if (n.slider[8] != master_slider) {
        lp.gain(master_slider/127.0);
    }
}

spork ~ visuals();
spork ~ controls();

while (true) {
    1::second => now;
}
