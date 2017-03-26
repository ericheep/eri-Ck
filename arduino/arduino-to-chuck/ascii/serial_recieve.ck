// Eric Heep
// May 2015

// basic serial protocol for receiving 
// ascii messages into ChucK from Arduino

SerialIO serial;
SerialIO.list() @=> string list[];

// prints our string array of serial devices
for(int i; i < list.cap(); i++) {
    <<< i, ":", list[i], "" >>>;
}

fun int device() {
    // assigns a 'usb' port as a serial port
    // granted you only have one USB device connected
    // otherwise you should manually assign the port
    int port;
    for (int i; i < list.cap(); i++) {
        if (list[i].find("usb") > 0) {
            i => port;
        }
    }
    <<< "-", "" >>>;
    <<< "Connecting to", list[port], "on port", port, "" >>>;
    return port;
}

serial.open(device(), SerialIO.B9600, SerialIO.ASCII);

// to store our messages
int data[0];

while (true) {
    // waits for an ascii val 
    serial.onInts(1) => now; 
    serial.getInts() @=> data;

    if (data != NULL && data[0] == 0xff) {
        serial.onInts(2) => now; 
        serial.getInts() @=> data;

        <<< "Incoming data:", data[0], data[1] >>>;
    }
}
