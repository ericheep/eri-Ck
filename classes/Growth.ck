// Exponential Growth Delay Class
// -~-~-~-~-~-~
// Eric Heep
// November 11th, 2013

public class Growth extends Chubgraph {
    // sets a hard limit of 64 echoes
    Echo ech[64];
    inlet => ech[0];
    inlet => outlet;
    ech[ech.cap() - 1] => outlet;
    for (int i; i < ech.cap() - 1; i++) {
        ech[i] => ech[i + 1];
        ech[i] => outlet;
    }
    
    // function for all parameters without the class
    fun void echoes (float fdbk, int num, dur length) {
        num $ float => float divisions;
        length/divisions => dur beatTime;        
        // calculates exponential growth, puts it into the Echo array
        0::samp => dur y;
        for (1 => int i; i < num + 1; i++ ) {
            Math.pow(Math.pow((1 + divisions),(1/divisions)),(i)) - 1 => float beat;    
            beat * beatTime => dur x;
            x - y => dur difference;
            beat * beatTime => y;                
            // sets max delay time as well as delay time
            difference => ech[i - 1].max => ech[i - 1].delay;
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
    echoes(.75, 16, 2::second);
}

/*
Impulse imp => Growth grow => dac;
grow.echoes(.9, 8, 2::second);

while(true) {
    1 => imp.next;
    2::second => now;
}
*/