// Eric Heep
// May 2015

// basic serial protocol for receiving an 
// array of bytes into ChucK from Arduino

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

serial.open(device(), SerialIO.B9600, SerialIO.BINARY);

// to store our messages
int byte;
int bytes[0];

while (true) {
    // waits for a byte
    serial.onByte() => now; 
    serial.getByte() => byte;

    // ensures we're receiving our bytes in order, 0xff == 255
    if (byte == 0xff) {
        serial.onBytes(2) => now; 
        serial.getBytes() @=> bytes;

        // recommended in the case that we crash by 
        // trying to read a null array
        if (bytes != NULL) {
            <<< "Incoming data:", bytes[0], bytes[1], "" >>>;
        }
    }
}
