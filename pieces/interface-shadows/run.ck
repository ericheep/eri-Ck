// master.ck
// Eric Heep

// communication classes
Machine.add(me.dir() + "/Handshake.ck");
Machine.add(me.dir() + "/HandshakeID.ck");
Machine.add(me.dir() + "/Puck.ck");
Machine.add(me.dir() + "/Pulse.ck");
Machine.add(me.dir() + "/RandomPulse.ck");

// midi class
Machine.add(me.dir() + "/NanoKontrol2.ck");

// main program
1.0::second => now;
Machine.add(me.dir() + "/interface-shadows.ck");
