// red-beast
// Eric Heep

// special osc sender for two projectors
Machine.add(me.dir() + "BeastOsc.ck");
Machine.add(me.dir() + "Utility.ck");

// classes that produce sound and send osc to Processing
Machine.add(me.dir() + "MultiSin.ck");
Machine.add(me.dir() + "SingleSin.ck");
Machine.add(me.dir() + "OrbitSin.ck");

// main progra\
Machine.add(me.dir() + "red_beast.ck");
