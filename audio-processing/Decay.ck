// ExpDelay.ck
// Eric Heep

public class ExpDecay extends Chubgraph {
    // sets a hard limit of 64 echoes
    Echo ech[64];
    inlet => ech[0];
    inlet => outlet;
    ech[ech.cap() - 1] => outlet;

    int num;

    for (int i; i < ech.cap() - 1; i++) {
        ech[i] => ech[i + 1];
        ech[i] => outlet;
    }

    //feedback(0.9);
    //length(1.0::second);
    //mix(1.0);

    // number of echoes
    fun void echoes(int n) {
        n => num;
    }
    
    // function for all parameters without the class
    fun void echoes(float fdbk, int n, dur length) {
        n => num;
        num $ float => float div;
        length/div => dur beatTime;        

        // calculates exponential growth, puts it into the Echo array
        0::samp => dur y;

        // calculates length of each echo
        for (1 => int i; i < num + 1; i++ ) {
            Math.pow(Math.pow((1 + div),(1/div)),(i)) - 1 => float beat;    
            beat * beatTime => dur x;
            x - y => dur difference;
            beat * beatTime => y;                
            // sets max delay time as well as delay time
            difference => ech[num - i].max => ech[num - i].delay;
        } 
        for (int i; i < num; i++) {
            fdbk => ech[i].gain;            
            1 => ech[i].mix;
        }
        for (num => int i; i < ech.cap(); i++) {
            0 => ech[i].gain;
            0 => ech[i].mix;            
        }   
    }
   /* 
    fun void feedback(float f) {
        for (int i; i < num; i++) {
            f => ech[i].gain;            
        }
        for (num => int i; i < ech.cap(); i++) {
            0.0 => ech[i].gain;
        }
    }

    fun void length(dur l) {
        echoes(num, l);
    }

    fun void mix(float m) {
        for (int i; i < num; i++) {
            m => ech[i].mix;
        } 
        for (num => int i; i < ech.cap(); i++) {
            0.0 => ech[i].mix;            
        }
    }
    */
}
/*
adc => ExpDecay exp => dac;

exp.feedback(0.54);
exp.echoes(16);
exp.length(2::second);

while (true) {
    1::second => now;
}
*/
