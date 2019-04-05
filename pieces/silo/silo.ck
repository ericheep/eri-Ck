// silo.ck

NanoKontrol2 nano;
Meepo meepo;
meepo.init();

dur meepoSpeed[2];
dur meepoHeartbeat[2];
int meepoVelocity[2];

fun void updateSpeed(int idx) {
    while (true) {
        nano.knob[idx] => now;
        nano.knob[idx].getNoteFloat() * 0.1::second => meepoSpeed[idx];
    }
}

fun void updateHeartbeat(int idx) {
    while (true) {
        nano.knob[idx + 2] => now;
        nano.knob[idx + 2].getNoteFloat() * 0.1::second => meepoHeartbeat[idx];
    }
}

fun void updateVelocity(int idx) {
    while (true) {
        nano.slider[idx] => now;
        nano.slider[idx].getNote() => meepoVelocity[idx];
    }
}

spork ~ updateSpeed(0);
spork ~ updateSpeed(1);
spork ~ updateVelocity(0);
spork ~ updateVelocity(1);
spork ~ updateHeartbeat(0);
spork ~ updateHeartbeat(1);

fun void note(int idx) {
    while(true) {
        meepoVelocity[idx] => int vel;

        if (meepoSpeed[idx]/samp == 0.0) {
            ms => now;
        } else {
            if (vel != 0) {
                meepo.note(idx, vel);
            }
            meepoSpeed[idx] => now;
        }
    }
}

fun void heartbeat(int idx) {
    while(true) {
        meepoVelocity[idx] => int vel;

        if (meepoHeartbeat[idx]/samp == 0.0) {
            ms => now;
        } else {
            Math.random2(2, 3) => int repeats;
            for (0 => int i; i < repeats; i++) {
                meepoHeartbeat[idx] => now;
                if (vel != 0) {
                    meepo.note(idx, vel);
                }
            }
            meepoHeartbeat[idx] * Math.random2f(16.8, 18.4) => now;
        }
    }
}

spork ~ note(0);
spork ~ note(1);
spork ~ heartbeat(0);
spork ~ heartbeat(1);

while (true) {
    second => now;
}
