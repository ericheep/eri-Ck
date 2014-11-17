// Eric Heep
// serial handling
SerialIO serial;
SerialIO.list() @=> string list[];

for(int i; i < list.cap(); i++) {
    <<< i, ":", list[i], "" >>>;
}

fun int device() {
    // assigns a 'usb' port as a serial port
    // granted you only have one USB device connected
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

while (true) {
    int data[2];
    serial.onBytes(2) => now; 
    serial.getBytes() @=> data;
    <<< data[0], data[1], "" >>>;
}


