// turns receiving osc messages into serial messages

// osc setup 
OscIn oin;
OscMsg omsg;

// midi setup
MidiIn min[10];
MidiMsg mmsg;
-1 => int port;

// IAC MIDI name
"Marimba" => string midi_name;
"IAC Driver " + midi_name => midi_name;

// OSC address
"/marimba" => string osc_name;

for (int i; i < min.cap(); i++) {
    // no print err
    min[i].printerr(0);
    
    // open the device
    if (min[i].open(i)) {
        if (min[i].name() == midi_name) {
            i => port;
            <<< "Connected to", min[port].name(), "" >>>;
        }
    }
    else break;
} 

if (port == -1) {
    <<< "MIDI port 'Marimba' not found", "" >>>;
    0 => port;
}

// fibonacci port number
11235 => oin.port;
oin.listenAll();

// serial setup 
SerialIO serial;
SerialIO.list() @=> string list[];
-1 => int serial_port;

for (int i; i < list.cap(); i++) {
    if (list[i].find("usb") > 0) {
        i => serial_port;
    }
}

// checks to see if an arduino is connected
if (serial_port == -1) {
    <<< "No usbmodem device detected", "" >>>;
    me.exit();
}

// serial connecting
if (!serial.open(serial_port, SerialIO.B9600, SerialIO.BINARY)) {
    <<< "Unable to open serial device:", "\t", list[serial_port] >>>;
}
else {
    <<< list[serial_port], "assigned to port", serial_port, "" >>>;
}

// note function
fun void note(int num, int vel) {
    // bitwise operations, allows note numbers 0-63 and note velocities 0-1023
    int bytes[2];
    (num << 2) | (vel >> 8) => bytes[0]; 
    vel & 255 => bytes[1];
    serial.writeBytes(bytes);
}

// required
fun void initialize() {
    2::second => now;
    [255, 255] @=> int ping[];
    serial.writeBytes(ping);
}

// osc to note function
fun void oscrecv(string address) {
    while (true) {
        oin => now;
        while (oin.recv(omsg)) {
            if (omsg.address == address) {
                note(omsg.getInt(0), omsg.getInt(1));
            }
        }
    } 
}

// midi to note function
fun void midirecv() {
    while (true) {
        min[port] => now;
        while (min[port].recv(mmsg)) {
            note(mmsg.data2, mmsg.data3);
        }
    }
}

// required start the marimba
initialize();

// change name to whichever address you want to use
spork ~ oscrecv(osc_name);
midirecv();
