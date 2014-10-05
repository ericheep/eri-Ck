//test.ck

//Binary bin;

/*
for (1 => int j; j < 5; j++) {
    for (int i; i < j * 64; i++) {
        bin.play(110.0, i, j, 0.05::second);
    }
    for (int i; i < j * 64; i++) {
        bin.play(440.0, i, j, 0.05::second);
    }
    for (int i; i < j * 64; i++) {
        bin.play(220.0, i, j, 0.05::second);
    }
    for (int i; i < j * 64; i++) {
        bin.play(330.0, i, j, 0.05::second);
    }
}


bin.play(55.0, 132890, 4, 10.0::second);
*/

//pan(15, -0.5, 1.0);

fun void pan(int b, float l, float r) {
    Math.fabs(l - r) => float d;
    for (int i; i < b; i++) {
        if (l > r) {
            <<< l - i/(b - 1.0) * d >>>; 
        }
        if (r > l) {
            <<< l + i/(b - 1.0) * d >>>; 
        }
        if (l == r) {
            // l =>
        }
    }
}


1.0 => float x;
1.0 => float in_min;
-1.0 => float in_max;
1.0 => float out_min;
-1.0 => float out_max;

<<< (x - in_min) * (out_max - out_min) / 2.0 + out_min >>>;
