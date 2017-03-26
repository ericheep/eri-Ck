OscSend procXmit;
procXmit.setHost("127.0.0.1", 12001);

20 => int max;
int inc, ctr;
0.1::second => dur loop;

while (true) {
    //(inc + 1) % 4 => inc;
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/leftLine","i");
        inc => procXmit.addInt;
        loop => now;   
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/rightLine","i");
        inc => procXmit.addInt;
        loop => now;   
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/upLine","i");
        inc => procXmit.addInt;
        loop => now;   
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/downLine","i");
        inc => procXmit.addInt;
        loop => now;   
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/nwLine","i");
        inc => procXmit.addInt;
        loop => now;
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/neLine","i");
        inc => procXmit.addInt;
        loop => now;
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/swLine","i");
        inc => procXmit.addInt;
        loop => now;
    }
    for (int i; i < max; i++) {
        Math.random2(0,max) => inc;
        //i => inc;
        procXmit.startMsg("/seLine","i");
        inc => procXmit.addInt;
        loop => now;
    }
    //procXmit.startMsg("/invert","i");
    //(ctr + 1) % 2 => ctr => procXmit.addInt;
    procXmit.startMsg("/scale","i");
    Math.random2(1,4) => procXmit.addInt;
    procXmit.startMsg("/redraw","i");
    1 => procXmit.addInt;
    procXmit.startMsg("/reset","i");
    1 => procXmit.addInt;
}