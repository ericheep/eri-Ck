// Envelope Follower with Sample Repeater
// -~-~-~-~-~-~
// Eric Heep
// November 7th, 2013

// sound chain
adc => Gain in => blackhole;
adc => LiSa mic => NRev rev => dac;
adc => dac;

// variables
0.05 => rev.mix;
int ctr, mod;
float recordTime;
1000 => float tempo;
[.06125, .08333, .125, .1875, .25, .333] @=> float rhythm[];

// envelope follower function
fun void amplitude(){
    while (true){
        if (Math.pow(in.last(),2) > 0.0035){
            ctr % 2 => mod;  
            spork ~ sampleRepeat();
            ctr++;
            0.5::second => now;
        }
        1::samp => now;            
    }
}    

// runs envelope follower at sample rate
spork ~ amplitude();

// sample repeater, turns off every other input
fun void sampleRepeat() {
    rhythm[Math.random2(0,5)] * tempo => float msRepeat;
    if (mod == 0) {
        <<< "Playing at a", msRepeat, "millisecond rhythm." >>>; 
    }
    msRepeat::ms => mic.duration;
    1 => mic.record;
    msRepeat::ms => now;
    0 => mic.record;
    1 => mic.play;
    while (mod == 0) {
        0::samp => mic.playPos;
        msRepeat::ms => now;
    }
    0 => mic.play;
}

while( true ){
    1::samp => now;   
}