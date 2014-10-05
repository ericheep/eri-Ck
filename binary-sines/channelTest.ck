// 0. left to right, low to high
// 6. random
// 7. rotate
Binary bi[2];
bi[0].adsr(30::ms, 0::ms, 1.0, 30::ms);
bi[1].adsr(30::ms, 0::ms, 1.0, 30::ms);

/*16 => int max;
int bit[max];

for (int i; i < bit.cap(); i++) {
    Math.pow(2, i + 1) $ int => bit[i];
}
*/

bi[0].rotate(1.0, -1.0, 0.0025);
bi[1].rotate(-1.0, 1.0, 0.0025);
    spork ~ bi[0].play(110, 10000, 1000::second);
    //spork ~ bi[1].play(220, i, 5::second); 



while (true) {
    1::second => now;
}
