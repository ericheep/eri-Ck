// red-beast
// Eric Heep

// special osc sender for two projectors
Machine.add(me.dir() + "BeastOsc.ck");
Machine.add(me.dir() + "Utility.ck");

Machine.add(me.dir() + "MultiPan.ck");

// NanoKontrol & Quneo
Machine.add(me.dir() + "NanoKontrol.ck");
Machine.add(me.dir() + "Quneo.ck");

// continuous classes
Machine.add(me.dir() + "MultiSin.ck");
Machine.add(me.dir() + "SingleSin.ck");
Machine.add(me.dir() + "OrbitSin.ck");
// Machine.add(me.dir() + "ChaoticSilence.ck");

// triggered classes
Machine.add(me.dir() + "BlinkSin.ck");
// Machine.add(me.dir() + "CrashSin.ck");
// Machine.add(me.dir() + "CrushSin.ck");
// Machine.add(me.dir() + "CrushSin.ck");

// live sampling classes
Machine.add(me.dir() + "Phonogene.ck");
Machine.add(me.dir() + "Reich.ck");
Machine.add(me.dir() + "Sort.ck");
Machine.add(me.dir() + "Micro.ck");


// main program
Machine.add(me.dir() + "red_beast.ck");
